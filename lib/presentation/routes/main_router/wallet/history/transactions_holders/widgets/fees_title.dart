import 'package:flutter/material.dart';

class FeesTitle extends StatelessWidget {
  final String fees;

  const FeesTitle({
    Key? key,
    required this.fees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        'Fees: $fees EVER',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
