import 'package:flutter/material.dart';

import '../theme.dart';

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    Key? key,
    this.size = 40.0,
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

class Badge extends StatelessWidget {
  const Badge({
    Key? key,
    this.counter = 0,
    this.counterSize = 14.0,
    this.size = 20.0,
    this.color = CrystalColor.badge,
  }) : super(key: key);

  final int counter;
  final double counterSize;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedOpacity(
          duration: kThemeAnimationDuration,
          curve: Curves.decelerate,
          opacity: counter > 0 ? 1.0 : 0.0,
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: size,
            height: size,
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: color,
            ),
            child: Center(
              child: Text(
                counter.toString(),
                style: TextStyle(
                  fontSize: counterSize,
                  letterSpacing: 0.75,
                ),
              ),
            ),
          ),
        ),
      );
}
