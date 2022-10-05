import 'package:flutter/material.dart';

class AnimatedOffstage extends StatefulWidget {
  final Duration duration;
  final bool offstage;
  final Widget child;

  const AnimatedOffstage({
    super.key,
    required this.duration,
    required this.offstage,
    required this.child,
  });

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
