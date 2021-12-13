import 'package:flutter/material.dart';

class TransactionTypeLabel extends StatelessWidget {
  final String text;
  final Color color;
  final BorderRadiusGeometry? borderRadius;

  const TransactionTypeLabel({
    Key? key,
    required this.text,
    required this.color,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color.withOpacity(0.15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
          ),
        ),
      );
}
