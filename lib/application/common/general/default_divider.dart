import 'package:flutter/material.dart';

class DefaultDivider extends StatelessWidget {
  final double bothIndent;

  const DefaultDivider({super.key, this.bothIndent = 0});

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 1,
      height: 1,
      indent: bothIndent,
      endIndent: bothIndent,
    );
  }
}
