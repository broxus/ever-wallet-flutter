import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final void Function()? onPressed;

  const CustomCloseButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: onPressed,
        icon: const Icon(Icons.close),
      );
}