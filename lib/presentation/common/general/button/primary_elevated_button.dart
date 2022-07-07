import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../util/colors.dart';
import '../../../util/extensions/context_extensions.dart';
import 'primary_button.dart';

class PrimaryElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  final bool isDestructive;

  const PrimaryElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final enabledColor = isDestructive ? ColorsRes.redLight : ColorsRes.darkBlue;
    final disabledColor = isDestructive ? ColorsRes.redLight : ColorsRes.lightBlue;

    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      height: 50,
      style: themeStyle.styles.primaryButtonStyle.copyWith(color: ColorsRes.white),
      backgroundColor: onPressed != null ? enabledColor : disabledColor,
    );
  }
}
