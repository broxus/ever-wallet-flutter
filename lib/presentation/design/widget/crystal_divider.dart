import 'package:flutter/material.dart';

class CrystalDivider extends StatelessWidget {
  final double height;
  final double minHeight;
  final double width;
  final double minWidth;

  const CrystalDivider({
    Key? key,
    this.height = 0,
    this.width = 0,
    this.minHeight = 0,
    this.minWidth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: kThemeAnimationDuration,
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: height,
        ),
      );
}
