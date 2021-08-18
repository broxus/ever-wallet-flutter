import 'package:flutter/material.dart';

const _kAppearanceDuration = Duration(milliseconds: 200);

class AnimatedAppearance extends StatefulWidget {
  const AnimatedAppearance({
    Key? key,
    this.curve = Curves.decelerate,
    this.duration = _kAppearanceDuration,
    this.delay = Duration.zero,
    this.offset = Offset.zero,
    this.showing = true,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final Curve curve;
  final Duration duration;
  final Duration delay;
  final Offset offset;

  final bool showing;

  @override
  _AnimatedAppearanceState createState() => _AnimatedAppearanceState();
}

class _AnimatedAppearanceState extends State<AnimatedAppearance> {
  final _appear = ValueNotifier<bool>(false);
  bool _initialized = false;

  @override
  void didUpdateWidget(covariant AnimatedAppearance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialized) _appear.value = widget.showing;
  }

  @override
  void initState() {
    super.initState();
    if (widget.showing) {
      WidgetsBinding.instance!.addPostFrameCallback(
        (_) => Future.delayed(
          widget.delay,
          () {
            if (mounted) {
              _appear.value = widget.showing;
              _initialized = true;
            }
          },
        ),
      );
    } else {
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _appear.value = false;
    super.dispose();
    _appear.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: _appear,
        builder: (context, appear, child) => IgnorePointer(
          ignoring: !appear,
          child: AnimatedOpacity(
            opacity: appear ? 1.0 : 0.0,
            duration: widget.duration,
            curve: widget.curve,
            child: TweenAnimationBuilder<Offset>(
              key: ValueKey('AnimatedAppearanceSlideBuilder_$appear'),
              tween: Tween<Offset>(
                begin: appear ? widget.offset : Offset.zero,
                end: Offset.zero,
              ),
              curve: widget.curve,
              duration: widget.duration,
              builder: (context, offset, child) => FractionalTranslation(
                translation: offset,
                child: child,
              ),
              child: child,
            ),
          ),
        ),
        child: widget.child,
      );
}
