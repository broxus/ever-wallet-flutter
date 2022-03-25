import 'package:flutter/material.dart';

class AnimatedFadeSlideIn extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final Offset offset;
  final Widget child;

  const AnimatedFadeSlideIn({
    Key? key,
    required this.duration,
    required this.delay,
    required this.offset,
    required this.child,
  }) : super(key: key);

  @override
  _AnimatedFadeSlideInState createState() => _AnimatedFadeSlideInState();
}

class _AnimatedFadeSlideInState extends State<AnimatedFadeSlideIn> with SingleTickerProviderStateMixin {
  late Offset offset;

  @override
  void initState() {
    super.initState();
    offset = widget.offset;
    Future<void>.delayed(widget.delay).then(
      (value) => setState(
        () => offset = Offset.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: widget.duration,
        opacity: offset == Offset.zero ? 1 : 0,
        child: IgnorePointer(
          ignoring: offset != Offset.zero,
          child: AnimatedSlide(
            duration: widget.duration,
            offset: offset,
            child: widget.child,
          ),
        ),
      );
}
