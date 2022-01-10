import 'package:flutter/material.dart';

class ConfirmsTitle extends StatelessWidget {
  final int signsReceived;
  final int signsRequired;

  const ConfirmsTitle({
    Key? key,
    required this.signsReceived,
    required this.signsRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        'Signed $signsReceived of $signsRequired',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
