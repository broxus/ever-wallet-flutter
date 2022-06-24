import 'package:flutter/material.dart';

import '../../../util/extensions/context_extensions.dart';
import 'primary_button.dart';

class TextPrimaryButton extends StatelessWidget {
  const TextPrimaryButton({
    required this.onPressed,
    Key? key,
    this.text,
    this.style,
    this.child,
    this.focusNode,
    this.radius,
    this.backgroundColor = Colors.transparent,
    this.height = kPrimaryButtonHeight,
    this.padding,
    this.pressStateColor,
    this.isLoading = false,
  }) : super(key: key);

  final String? text;
  final TextStyle? style;
  final Widget? child;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final BorderRadius? radius;
  final double height;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color? pressStateColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeStyle.colors;

    return PrimaryButton(
      onPressed: onPressed,
      text: text,
      style: style,
      focusNode: focusNode,
      radius: radius,
      backgroundColor: backgroundColor,
      height: height,
      padding: padding,
      presstateColor: pressStateColor ?? colors.primaryPressStateColor,
      child: child,
    );
  }
}
