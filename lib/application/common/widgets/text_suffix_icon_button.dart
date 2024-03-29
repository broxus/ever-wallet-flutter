import 'package:flutter/material.dart';

class SuffixIconButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget icon;

  const SuffixIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: icon,
      );
}
