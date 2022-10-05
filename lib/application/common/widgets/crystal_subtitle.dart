import 'package:flutter/material.dart';

class CrystalSubtitle extends StatelessWidget {
  final String text;

  const CrystalSubtitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 16,
        ),
      );
}
