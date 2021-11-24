import 'package:flutter/material.dart';

class CrystalTitle extends StatelessWidget {
  final String text;

  const CrystalTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.start,
      );
}
