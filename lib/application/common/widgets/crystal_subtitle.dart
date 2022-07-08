import 'package:flutter/material.dart';

class CrystalSubtitle extends StatelessWidget {
  final String text;

  const CrystalSubtitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 16,
        ),
      );
}
