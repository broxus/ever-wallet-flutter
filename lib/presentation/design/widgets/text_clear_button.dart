import 'package:flutter/material.dart';

class TextClearButton extends StatelessWidget {
  final TextEditingController controller;

  const TextClearButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: () {
          controller.clear();
          Form.of(context)?.validate();
        },
        icon: const Icon(Icons.clear),
      );
}
