import 'package:flutter/material.dart';

class CrystalTitle extends StatelessWidget {
  final String text;

  const CrystalTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.start,
      );
}
