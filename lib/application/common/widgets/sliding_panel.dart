import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

enum SlideDirection {
  up,
  down,
}

enum PanelState { opened, closed, hidden }

class SlidingUpPanel extends StatefulWidget {
  final Widget? panel;

  final Widget Function(ScrollController sc)? panelBuilder;

  final Widget? collapsed;

  final Widget? body;

  final Widget? header;

  final Widget? footer;

  final double minHeight;

  final double maxHeight;

  final double? snapPoint;

  final Border? border;

  final BorderRadiusGeometry? borderRadius;

  final List<BoxShadow>? boxShadow;

  final Color color;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final bool renderPanelSheet;

  final bool panelSnapping;

  final PanelController? controller;

  final bool backdropEnabled;

  final Color backdropColor;

  final double backdropOpacity;

  final bool backdropTapClosesPanel;

  final void Function(double position)? onPanelSlide;

  final VoidCallback? onPanelOpened;

  final VoidCallback? onPanelClosed;

  final bool parallaxEnabled;

  final double parallaxOffset;

  final bool isDraggable;

  final SlideDirection slideDirection;

  const SlidingUpPanel({
    Key? key,
    this.panel,
    this.panelBuilder,
    this.body,
    this.collapsed,
    this.minHeight = 100,
    this.maxHeight = 500,
    this.snapPoint,
    this.border,
    this.borderRadius,
    this.boxShadow = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      )
    ],
    this.color = Colors.white,
    this.padding,
    this.margin,
    this.renderPanelSheet = true,
    this.panelSnapping = true,
    this.controller,
    this.backdropEnabled = false,
    this.backdropColor = Colors.black,
    this.backdropOpacity = 0.5,
    this.backdropTapClosesPanel = true,
    this.onPanelSlide,
    this.onPanelOpened,
    this.onPanelClosed,
    this.parallaxEnabled = false,
    this.parallaxOffset = 0.1,
    this.isDraggable = true,
    this.slideDirection = SlideDirection.up,
    this.header,
    this.footer,
  })  : assert(panel != null || panelBuilder != null),
        assert(0 <= backdropOpacity && backdropOpacity <= 1),
        assert(snapPoint == null || 0 < snapPoint && snapPoint < 1),
        super(key: key);

  @override
  _SlidingUpPanelState createState() => _SlidingUpPanelState();
}

class _SlidingUpPanelState extends State<SlidingUpPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final ScrollController _sc;

  final _modalBuilderKey = GlobalKey();
  final _vt = VelocityTracker.withKind(PointerDeviceKind.touch);

  bool _scrollingEnabled = false;
  late bool _isPanelVisible;
  bool _isPanelLocked = false;

  @override
  void initState() {
    super.initState();
    final initialState = widget.controller?.initialState ?? PanelState.closed;

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: initialState != PanelState.opened ? 0 : 1,
    )..addListener(() {
        if (widget.onPanelSlide != null) widget.onPanelSlide?.call(_ac.value);

        if (widget.onPanelOpened != null && _ac.value == 1) widget.onPanelOpened!();

        if (widget.onPanelClosed != null && _ac.value == 0) widget.onPanelClosed!();
      });

    _sc = ScrollController();
    _sc.addListener(() {
      if (widget.isDraggable && !_scrollingEnabled) _sc.jumpTo(0);
    });

    _isPanelVisible = initialState != PanelState.hidden;
    widget.controller?._panelState = this;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment:
          widget.slideDirection == SlideDirection.up ? Alignment.bottomCenter : Alignment.topCenter,
      children: <Widget>[
        if (widget.body != null)
          AnimatedBuilder(
            animation: _ac,
            builder: (context, child) {
              return Positioned(
                top: widget.parallaxEnabled ? _getParallax() : 0,
                child: child ?? const SizedBox(),
              );
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: widget.body,
            ),
          )
        else
          Container(),
        if (!widget.backdropEnabled)
          Container()
        else
          GestureDetector(
            onVerticalDragEnd: widget.backdropTapClosesPanel
                ? (sd) {
                    if ((widget.slideDirection == SlideDirection.up ? 1 : -1) *
                            sd.velocity.pixelsPerSecond.dy >
                        0) {
                      _close();
                    }
                  }
                : null,
            onTap: widget.backdropTapClosesPanel ? () => _close() : null,
            child: AnimatedBuilder(
              animation: _ac,
              builder: (context, _) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: _ac.value == 0
                      ? null
                      : widget.backdropColor.withOpacity(widget.backdropOpacity * _ac.value),
                );
              },
            ),
          ),
        _gestureHandler(
          child: AnimatedBuilder(
            animation: _ac,
            builder: (context, child) => TweenAnimationBuilder<double>(
              key: _modalBuilderKey,
              duration: kThemeAnimationDuration,
              tween: Tween(end: _isPanelVisible ? widget.minHeight : 0),
              builder: (context, minHeight, child) => Container(
                height: _ac.value * (widget.maxHeight - minHeight) + minHeight,
                margin: widget.margin,
                padding: widget.padding,
                clipBehavior: widget.renderPanelSheet ? Clip.antiAlias : Clip.none,
                decoration: widget.renderPanelSheet
                    ? BoxDecoration(
                        border: widget.border,
                        borderRadius: widget.borderRadius,
                        boxShadow: widget.boxShadow,
                        color: widget.color,
                      )
                    : null,
                child: child,
              ),
              child: child,
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: widget.slideDirection == SlideDirection.up ? 0 : null,
                  bottom: widget.slideDirection == SlideDirection.down ? 0 : null,
                  width: MediaQuery.of(context).size.width -
                      (widget.margin != null ? widget.margin!.horizontal : 0) -
                      (widget.padding != null ? widget.padding!.horizontal : 0),
                  child: SizedBox(
                    height: widget.maxHeight,
                    child: widget.panel ?? widget.panelBuilder!(_sc),
                  ),
                ),
                if (widget.header != null)
                  Positioned(
                    top: widget.slideDirection == SlideDirection.up ? 0 : null,
                    bottom: widget.slideDirection == SlideDirection.down ? 0 : null,
                    child: widget.header ?? const SizedBox(),
                  )
                else
                  Container(),
                if (widget.footer != null)
                  Positioned(
                    top: widget.slideDirection == SlideDirection.up ? null : 0,
                    bottom: widget.slideDirection == SlideDirection.down ? null : 0,
                    child: widget.footer ?? const SizedBox(),
                  )
                else
                  Container(),
                Positioned(
                  top: widget.slideDirection == SlideDirection.up ? 0 : null,
                  bottom: widget.slideDirection == SlideDirection.down ? 0 : null,
                  width: MediaQuery.of(context).size.width -
                      (widget.margin != null ? widget.margin!.horizontal : 0) -
                      (widget.padding != null ? widget.padding!.horizontal : 0),
                  child: AnimatedContainer(
                    duration: kThemeAnimationDuration,
                    height: widget.minHeight,
                    child: widget.collapsed == null
                        ? Container()
                        : FadeTransition(
                            opacity: Tween<double>(begin: 1, end: 0).animate(_ac),
                            child: IgnorePointer(
                              ignoring: _isPanelOpen,
                              child: widget.collapsed,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  double _getParallax() {
    if (widget.slideDirection == SlideDirection.up) {
      return -_ac.value * (widget.maxHeight - widget.minHeight) * widget.parallaxOffset;
    } else {
      return _ac.value * (widget.maxHeight - widget.minHeight) * widget.parallaxOffset;
    }
  }

  Widget _gestureHandler({required Widget child}) {
    if (!widget.isDraggable) return child;

    if (widget.panel != null) {
      return GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails dets) => _onGestureSlide(dets.delta.dy),
        onVerticalDragEnd: (DragEndDetails dets) => _onGestureEnd(dets.velocity),
        child: child,
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent p) => _vt.addPosition(p.timeStamp, p.position),
      onPointerMove: (PointerMoveEvent p) {
        _vt.addPosition(p.timeStamp, p.position);
        _onGestureSlide(p.delta.dy);
      },
      onPointerUp: (PointerUpEvent p) => _onGestureEnd(_vt.getVelocity()),
      child: child,
    );
  }

  void _onGestureSlide(double dy) {
    if (_isPanelLocked) return;

    if (!_scrollingEnabled) {
      if (widget.slideDirection == SlideDirection.up) {
        _ac.value -= dy / (widget.maxHeight - widget.minHeight);
      } else {
        _ac.value += dy / (widget.maxHeight - widget.minHeight);
      }
    }

    if (_isPanelOpen && _sc.hasClients && _sc.offset <= 0) {
      if (dy < 0) {
        _scrollingEnabled = true;
      } else {
        _scrollingEnabled = false;
      }
    }
  }

  void _onGestureEnd(Velocity v) {
    const minFlingVelocity = 365;
    const kSnap = 8;

    if (_ac.isAnimating) return;

    if (_isPanelOpen && _scrollingEnabled) return;

    double visualVelocity = -v.pixelsPerSecond.dy / (widget.maxHeight - widget.minHeight);

    if (widget.slideDirection == SlideDirection.down) visualVelocity = -visualVelocity;

    final d2Close = _ac.value;
    final d2Open = 1 - _ac.value;
    final d2Snap = ((widget.snapPoint ?? 3) - _ac.value).abs();
    final minDistance = min(d2Close, min(d2Snap, d2Open));

    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity || minDistance == d2Snap) {
          _ac.fling(velocity: visualVelocity);
        } else {
          _flingPanelToPosition(widget.snapPoint!, visualVelocity);
        }
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);
      } else {
        _ac.animateTo(
          _ac.value + visualVelocity * 0.16,
          duration: const Duration(milliseconds: 410),
          curve: Curves.decelerate,
        );
      }

      return;
    }

    if (widget.panelSnapping) {
      if (minDistance == d2Close) {
        _close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.snapPoint!, visualVelocity);
      } else {
        _open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 500,
      ),
      _ac.value,
      targetPos,
      velocity,
    );

    _ac.animateWith(simulation);
  }

  Future<void> _resetScroll([
    Duration duration = const Duration(milliseconds: 250),
  ]) async {
    if (_scrollingEnabled) {
      await _sc.animateTo(
        0,
        duration: duration,
        curve: Curves.decelerate,
      );
      _scrollingEnabled = false;
    }
  }

  Future<void> _close() async {
    await Future.wait([
      _resetScroll(),
      _ac.fling(velocity: -1),
    ]);
  }

  Future<void> _open() {
    return _ac.fling();
  }

  Future<void> _hide() {
    return _ac.fling(velocity: -1).then((x) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  Future<void> _show() {
    setState(() {
      _isPanelVisible = true;
    });
    return _ac.fling(velocity: -1);
  }

  Future<void> _lock() async {
    _isPanelLocked = true;
  }

  Future<void> _unlock() async {
    _isPanelLocked = false;
  }

  Future<void> _animatePanelToPosition(
    double value, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(0 <= value && value <= 1);
    return _ac.animateTo(value, duration: duration, curve: curve);
  }

  Future<void> _animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(widget.snapPoint != null);
    return _ac.animateTo(widget.snapPoint!, duration: duration, curve: curve);
  }

  set _panelPosition(double value) {
    assert(0 <= value && value <= 1);
    _ac.value = value;
  }

  double get _panelPosition => _ac.value;

  bool get _isPanelAnimating => _ac.isAnimating;

  bool get _isPanelOpen => _ac.value >= 0.99;

  bool get _isPanelClosed => _ac.value <= 0.01;

  bool get _isPanelShown => _isPanelVisible;
}

class PanelController {
  PanelController({
    this.initialState = PanelState.closed,
  });

  final PanelState initialState;
  _SlidingUpPanelState? _panelState;

  bool get isAttached => _panelState != null;

  Future<void> resetScroll() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._resetScroll();
  }

  Future<void> close() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._close();
  }

  Future<void> open() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._open();
  }

  Future<void> hide() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._hide();
  }

  Future<void> show() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._show();
  }

  Future<void> lock() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._lock();
  }

  Future<void> unlock() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._unlock();
  }

  Future<void> animatePanelToPosition(
    double value, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    assert(0 <= value && value <= 1);
    return _panelState!._animatePanelToPosition(value, duration: duration, curve: curve);
  }

  Future<void> animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    assert(
      _panelState!.widget.snapPoint != null,
      'SlidingUpPanel snapPoint property must not be null',
    );
    return _panelState!._animatePanelToSnapPoint(duration: duration, curve: curve);
  }

  set panelPosition(double value) {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    assert(0 <= value && value <= 1);
    _panelState!._panelPosition = value;
  }

  double get panelPosition {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._panelPosition;
  }

  bool get isPanelAnimating {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelAnimating;
  }

  bool get isPanelOpen {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelOpen;
  }

  bool get isPanelClosed {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelClosed;
  }

  bool get isPanelShown {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelShown;
  }
}
