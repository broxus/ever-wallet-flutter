import 'package:flutter/material.dart';

import '../theme.dart';
import 'expandable_page_view/expandable_page_view.dart';

const _titleTransitionDuration = Duration(milliseconds: 400);
const _pageTransitionDuration = Duration(milliseconds: 400);
const _sizeChangeDuration = Duration(milliseconds: 250);

class ModalFlowBase extends StatefulWidget {
  const ModalFlowBase({
    Key? key,
    required this.pageController,
    required this.activeTitle,
    required this.pages,
    this.layoutBuilder = _kDefaultLayoutBuilder,
    this.estimatedPageSize = 500,
    this.onWillPop,
  }) : super(key: key);

  final PageController pageController;
  final String activeTitle;
  final List<Widget> pages;
  final Widget Function(BuildContext, Widget) layoutBuilder;

  final double estimatedPageSize;
  final WillPopCallback? onWillPop;

  static Widget _kDefaultLayoutBuilder(BuildContext context, Widget child) => SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16),
        child: child,
      );

  @override
  _ModalFlowBaseState createState() => _ModalFlowBaseState();
}

class _ModalFlowBaseState extends State<ModalFlowBase> {
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: widget.onWillPop,
        child: _ChildBuilder(
          layoutBuilder: widget.layoutBuilder,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 32, bottom: 24),
                child: AnimatedSwitcher(
                  duration: _titleTransitionDuration,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: TweenSequence<double>([
                      TweenSequenceItem(tween: ConstantTween(0), weight: 3),
                      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
                    ]).animate(animation),
                    child: child,
                  ),
                  child: Align(
                    key: ValueKey('modal_flow_${widget.activeTitle}'),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.activeTitle,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: CrystalColor.fontDark,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) => ExpandablePageView(
                    estimatedPageSize: widget.estimatedPageSize,
                    maxHeight: constraints.maxHeight,
                    controller: widget.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    animationDuration: _sizeChangeDuration,
                    children: widget.pages,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ChildBuilder extends StatelessWidget {
  const _ChildBuilder({
    Key? key,
    required this.layoutBuilder,
    required this.child,
  }) : super(key: key);

  final Widget Function(BuildContext, Widget) layoutBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) => layoutBuilder(context, child);
}

extension ModalPageTransition on PageController {
  Future<void> openAt(int index) => animateToPage(index, duration: _pageTransitionDuration, curve: Curves.decelerate);
}
