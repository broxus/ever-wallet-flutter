import 'package:flutter/material.dart';

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    Key? key,
    this.size = 40,
    required this.color,
    this.icon,
  }) : super(key: key);

  final Color color;

  final double size;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          clipBehavior: Clip.antiAlias,
          width: size,
          height: size,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: color,
          ),
          child: Center(
            child: icon,
          ),
        ),
      );
}
