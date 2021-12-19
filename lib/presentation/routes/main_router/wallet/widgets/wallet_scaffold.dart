import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../design/design.dart';
import '../../../../design/widgets/sliding_panel.dart';

class WalletScaffold extends StatefulWidget {
  final Widget body;
  final Widget Function(ScrollController) modalBody;
  final PanelController? modalController;
  final bool expand;
  final bool isScrollControlled;
  final bool isModalDragEnabled;

  const WalletScaffold({
    Key? key,
    this.isModalDragEnabled = true,
    this.expand = true,
    this.isScrollControlled = true,
    this.modalController,
    required this.body,
    required this.modalBody,
  }) : super(key: key);

  @override
  _WalletScaffoldState createState() => _WalletScaffoldState();
}

class _WalletScaffoldState extends State<WalletScaffold> {
  final _modalSize = ValueNotifier<_ModalSize>(const _ModalSize.empty());
  final _bodyKey = GlobalKey();
  final _modalBodyKey = GlobalKey();
  double _contentHeight = 0;

  @override
  void didUpdateWidget(covariant WalletScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _modalSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CrystalColor.background,
        body: ValueListenableBuilder<_ModalSize>(
          valueListenable: _modalSize,
          builder: (context, size, child) => SlidingUpPanel(
            controller: widget.modalController,
            panelBuilder: (controller) => _singleChildScrollWrap(
              enabled: !widget.isScrollControlled,
              controller: controller,
              child: KeyedSubtree(
                key: _modalBodyKey,
                child: Padding(
                  padding: EdgeInsets.only(bottom: context.safeArea.bottom),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: widget.modalBody(controller),
                  ),
                ),
              ),
            ),
            parallaxEnabled: true,
            isDraggable: widget.isModalDragEnabled && size.expandable,
            parallaxOffset: 0.05,
            backdropEnabled: true,
            renderPanelSheet: size.isValid,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Platform.isIOS ? 12 : 0)),
            boxShadow: const [BoxShadow(color: CrystalColor.shadow, offset: Offset(0, 8), blurRadius: 16)],
            maxHeight: size.maxHeight,
            minHeight: size.minHeight,
            header: Platform.isIOS && widget.isModalDragEnabled ? _dragHeader() : null,
            body: child,
          ),
          child: Column(
            children: [
              KeyedSubtree(key: _bodyKey, child: widget.body),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    SchedulerBinding.instance
                        ?.addPostFrameCallback((timeStamp) => _calculateModalHeight(constraints.maxHeight - 80));
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _singleChildScrollWrap({
    required Widget child,
    required ScrollController controller,
    required bool enabled,
  }) =>
      enabled
          ? SingleChildScrollView(
              controller: controller,
              padding: EdgeInsets.zero,
              child: child,
            )
          : child;

  Widget _dragHeader() => SizedBox(
        height: 18,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            height: 3,
            width: 48,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              color: CrystalColor.cursorColor,
            ),
          ),
        ),
      );

  void _calculateModalHeight([double? height]) {
    final box = _modalBodyKey.currentContext?.findRenderObject() as RenderBox?;
    final screenHeight = context.screenSize.height * 0.85 - 80;

    late double minHeight;
    late final double maxHeight;

    if (box != null) {
      final modalHeight = box.size.height;
      _contentHeight = modalHeight;
    }

    if (widget.expand) {
      minHeight = height ?? _contentHeight;
      maxHeight = math.max(minHeight, screenHeight);
    } else {
      maxHeight = math.min(_contentHeight, screenHeight);
      minHeight = math.min(_contentHeight, height ?? _contentHeight);
    }

    _modalSize.value = _ModalSize(minHeight, maxHeight);
  }
}

class _ModalSize {
  const _ModalSize(this.minHeight, this.maxHeight);

  const _ModalSize.empty()
      : minHeight = 0,
        maxHeight = 0;

  final double minHeight;
  final double maxHeight;

  bool get isValid => maxHeight > 0 && maxHeight >= minHeight;

  bool get expandable => maxHeight - minHeight > 0;
}
