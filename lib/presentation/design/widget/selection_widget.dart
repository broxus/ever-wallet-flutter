import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class SelectionWidget extends StatefulWidget {
  const SelectionWidget({
    Key? key,
    required this.child,
    required this.overlay,
    this.enabled = true,
    this.configuration = const SelectionConfiguration(),
    this.controller,
  }) : super(key: key);

  final Widget Function(bool isHightlighted) child;
  final WidgetBuilder overlay;

  final SelectionController? controller;
  final SelectionConfiguration configuration;
  final bool enabled;

  @override
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  final _positionKey = GlobalKey();
  final _objectKey = GlobalKey();
  final _selection = ValueNotifier<bool>(false);

  final _targetLink = LayerLink();

  OverlayEntry? _overlayEntry;

  Rect? _objectPosition;
  Rect? _overlayPosition;

  PointerDataPacketCallback? _flutterCallback;

  Rect? _keyPosition(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) return null;

    final Rect editingRegion = Rect.fromPoints(
      renderObject.localToGlobal(Offset.zero),
      renderObject.localToGlobal(renderObject.size.bottomRight(Offset.zero)),
    );

    return editingRegion;
  }

  void _holdGesture(PointerDataPacket packet) {
    if (!mounted) return;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final pointer = packet.data[0];
    if (pointer.change == PointerChange.down) {
      _overlayPosition = null;
      _objectPosition = null;
    }

    final offset = Offset(pointer.physicalX, pointer.physicalY) / pixelRatio;
    final objectPosition = _keyPosition(_objectKey);
    if (_objectPosition != null && !_objectPosition!.overlaps(objectPosition!)) {
      return _dismiss();
    }

    final radius = math.min(pointer.radiusMajor, (objectPosition?.shortestSide ?? 0) / 4);

    _objectPosition ??= _keyPosition(_objectKey)?.inflate(radius);
    if (_objectPosition != null && _objectPosition!.contains(offset)) return;

    _overlayPosition ??= _keyPosition(_positionKey)?.inflate(radius);
    if (_overlayPosition != null &&
        _overlayPosition!.contains(offset) &&
        (!widget.configuration.autoClose || pointer.change != PointerChange.up)) {
      return;
    }

    _dismiss();
  }

  @override
  void didUpdateWidget(covariant SelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?._state = this;
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final flutterWindow = GestureBinding.instance?.window;
      if (flutterWindow != null) {
        _flutterCallback = flutterWindow.onPointerDataPacket;
        flutterWindow.onPointerDataPacket = (data) {
          _holdGesture(data);
          _flutterCallback?.call(data);
        };
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    widget.controller?.dispose();

    final flutterWindow = GestureBinding.instance?.window;
    if (flutterWindow != null && _flutterCallback != null) {
      flutterWindow.onPointerDataPacket = _flutterCallback;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        onDoubleTap: widget.configuration.openOnDoubleTap ? _show : () {},
        onLongPress: widget.configuration.openOnHold ? _show : () {},
        child: ValueListenableBuilder<bool>(
          valueListenable: _selection,
          builder: (context, selected, _) => TweenAnimationBuilder<double>(
            duration: const Duration(),
            tween: Tween(end: selected ? 1 : 0),
            builder: (context, opacity, child) {
              final color = widget.configuration.highlightColor;
              return color == null
                  ? child!
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withOpacity(color.opacity * opacity),
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                      ),
                      child: child,
                    );
            },
            child: CompositedTransformTarget(
              link: _targetLink,
              child: Padding(
                key: _objectKey,
                padding: widget.configuration.highlightColor == null
                    ? EdgeInsets.zero
                    : widget.configuration.highlightPadding,
                child: widget.child(selected),
              ),
            ),
          ),
        ),
      );

  void _show() {
    if (!widget.enabled || _selection.value) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    final objectPosition = _keyPosition(_objectKey);
    if (objectPosition == null) return;

    _overlayEntry = OverlayEntry(
      builder: (_context) => CompositedTransformFollower(
        link: _targetLink,
        showWhenUnlinked: false,
        targetAnchor: widget.configuration.parentAnchor,
        followerAnchor: widget.configuration.childAnchor,
        child: Align(
          alignment: widget.configuration.childAnchor,
          child: ValueListenableBuilder<bool>(
            valueListenable: _selection,
            builder: (context, value, child) => AnimatedOpacity(
              duration: const Duration(),
              opacity: value ? 1 : 0,
              child: child,
            ),
            child: KeyedSubtree(
              key: _positionKey,
              child: widget.overlay(_context),
            ),
          ),
        ),
      ),
    );

    final state = Overlay.of(context);

    if (state != null) {
      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        _selection.value = true;
        if (widget.configuration.hapticOnShown) HapticFeedback.lightImpact();
        widget.controller?._onShown?.call();
      });

      state.insert(_overlayEntry!);
    }
  }

  void _dismiss() {
    if (!_selection.value) return;

    _selection.value = false;
    final entry = _overlayEntry;
    Future.delayed(const Duration(milliseconds: 175), () => entry?.remove());
    _overlayEntry = null;

    widget.controller?._onDismiss?.call();
  }

  void _onTap() {
    if (widget.configuration.openOnTap && !_selection.value) {
      _show();
    } else {
      _dismiss();
    }
  }
}

class SelectionController {
  SelectionController({
    VoidCallback? onShown,
    VoidCallback? onDismiss,
  })  : _onShown = onShown,
        _onDismiss = onDismiss;

  _SelectionWidgetState? _state;

  VoidCallback? _onShown;
  VoidCallback? _onDismiss;

  bool get isShowing => _state?._selection.value ?? false;

  bool get isDismissed => !isShowing;

  void dispose() {
    _onShown = null;
    _onDismiss = null;
  }

  void dismiss() => _state?._dismiss();

  void show() => _state?._show();
}

class SelectionConfiguration {
  const SelectionConfiguration({
    this.openOnTap = false,
    this.openOnDoubleTap = true,
    this.openOnHold = true,
    this.parentAnchor = Alignment.topCenter,
    this.childAnchor = Alignment.bottomCenter,
    this.hapticOnShown = true,
    this.autoClose = true,
    this.highlightPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.highlightColor,
  });

  final Color? highlightColor;
  final EdgeInsets highlightPadding;

  final Alignment parentAnchor;
  final Alignment childAnchor;

  final bool openOnTap;
  final bool openOnDoubleTap;
  final bool openOnHold;
  final bool autoClose;
  final bool hapticOnShown;
}
