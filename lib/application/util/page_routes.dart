import 'package:flutter/material.dart';

class NoAnimationPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  @override
  final String? barrierLabel;

  NoAnimationPageRoute({
    required this.builder,
    this.barrierLabel,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;
}
