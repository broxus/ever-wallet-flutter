import 'package:flutter/material.dart';

class TextFieldIndexIcon extends StatelessWidget {
  final int index;

  const TextFieldIndexIcon({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 24,
        child: Center(
          child: Text(
            '${index + 1}.',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
