import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

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
    this.fillWidth = true,
  }) : super(key: key);

  factory TextPrimaryButton.appBar({
    required VoidCallback onPressed,
    String? text,
    TextStyle? style,
    Widget? child,
    FocusNode? focusNode,
    Color backgroundColor = Colors.transparent,
    EdgeInsets? padding,
    Color? pressStateColor,
    bool fillWidth = false,
    Key? key,
  }) =>
      TextPrimaryButton(
        onPressed: onPressed,
        key: key,
        radius: BorderRadius.circular(10),
        style: style,
        padding: padding,
        height: kAppBarButtonSize,
        text: text,
        backgroundColor: backgroundColor,
        focusNode: focusNode,
        pressStateColor: pressStateColor,
        fillWidth: fillWidth,
        child: child,
      );

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
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeStyle.colors;
    final button = PrimaryButton(
      onPressed: onPressed,
      text: text,
      style: style,
      focusNode: focusNode,
      radius: radius,
      backgroundColor: backgroundColor,
      height: height,
      padding: padding,
      presstateColor: pressStateColor ?? colors.primaryPressStateColor,
      fillWidth: fillWidth,
      child: child,
    );
    if (fillWidth) {
      return Center(child: button);
    }
    return button;
  }
}
