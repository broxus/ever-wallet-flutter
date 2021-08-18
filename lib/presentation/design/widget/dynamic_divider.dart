import 'package:flutter/material.dart';

class CrystalDivider extends StatelessWidget {
  const CrystalDivider({
    Key? key,
    this.height = 0.0,
    this.width = 0.0,
    this.minHeight = 0.0,
    this.minWidth = 0.0,
  }) : super(key: key);

  final double height;
  final double minHeight;

  final double width;
  final double minWidth;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: kThemeAnimationDuration,
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: height,
        ),
      );
}
