import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final TextStyle? style;

  const CustomTextButton({
    super.key,
    this.onPressed,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 4,
        ),
        child: GestureDetector(
          onTap: onPressed,
          child: Text(
            text,
            style: style,
          ),
        ),
      );
}
