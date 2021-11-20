import 'package:flutter/material.dart';

class ModalTitle extends StatelessWidget {
  final String data;

  const ModalTitle(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        data,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
      );
}
