import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;

  final bool isDestructive;

  const PrimaryElevatedButton({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final enabledColor = isDestructive ? ColorsRes.redLight : ColorsRes.darkBlue;
    final disabledColor = isDestructive ? ColorsRes.redLight : ColorsRes.lightBlue;

    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      style: themeStyle.styles.primaryButtonStyle.copyWith(color: ColorsRes.white),
      backgroundColor: onPressed != null ? enabledColor : disabledColor,
      child: child,
    );
  }
}
