import 'package:flutter/material.dart';

class AnimatedVisibility extends StatefulWidget {
  final Duration duration;
  final Widget child;
  final bool visible;

  const AnimatedVisibility({
    Key? key,
    required this.duration,
    required this.visible,
    required this.child,
  }) : super(key: key);

  @override
  _AnimatedVisibilityState createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility> {
  bool appear = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() => appear = widget.visible);
      }
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: appear ? 1 : 0,
        duration: widget.duration,
        child: widget.child,
      );
}
