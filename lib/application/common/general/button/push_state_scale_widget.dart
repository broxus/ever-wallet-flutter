import 'package:flutter/material.dart';

/// coefficient of scaling in percent
const _scaleRatio = 5.0;

/// PressState with resizing widget
class PushStateScaleWidget extends StatefulWidget {
  const PushStateScaleWidget({
    required this.child,
    super.key,
    this.onPressed,
    this.onHighlightChanged,
    this.radius,
    this.animationDuration = const Duration(milliseconds: 50),
    this.onLongPress,
    this.height,
    this.width,
  });

  final double? height;
  final double? width;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final BorderRadius? radius;
  final Duration animationDuration;

  /// Action when user press and holds
  final ValueChanged<bool>? onHighlightChanged;

  @override
  _PushStateScaleWidgetState createState() => _PushStateScaleWidgetState();
}

class _PushStateScaleWidgetState extends State<PushStateScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _doubleAnimation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    _doubleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      _controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    return InkResponse(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onHighlightChanged: (isPressed) {
        if (isPressed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
        widget.onHighlightChanged?.call(isPressed);
      },
      onLongPress: widget.onLongPress,
      onTap: widget.onPressed,
      child: Transform.scale(
        scale: 1.0 - (_doubleAnimation.value * _scaleRatio / 100),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.radius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
