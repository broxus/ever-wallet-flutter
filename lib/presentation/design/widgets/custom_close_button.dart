import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final void Function()? onPressed;

  const CustomCloseButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onPressed,
      icon: const Icon(Icons.close),
    );
  }
}
