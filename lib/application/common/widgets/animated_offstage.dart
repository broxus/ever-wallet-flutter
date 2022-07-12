import 'package:flutter/material.dart';

class AnimatedOffstage extends StatefulWidget {
  final Duration duration;
  final bool offstage;
  final Widget child;

  const AnimatedOffstage({
    Key? key,
    required this.duration,
    required this.offstage,
    required this.child,
  }) : super(key: key);

  @override
  _AnimatedOffstageState createState() => _AnimatedOffstageState();
}

class _AnimatedOffstageState extends State<AnimatedOffstage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: widget.duration,
        child: widget.offstage ? widget.child : const SizedBox(),
      );
}
