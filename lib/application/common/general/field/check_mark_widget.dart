import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Mark for checkbox with 3 states
class CheckMarkWidget extends StatelessWidget {
  const CheckMarkWidget({
    super.key,
    this.size = 18,
    this.hasError = false,
    this.isChecked = false,
    this.fill = false,
    this.color,
    this.checkMarkColor,
  });

  final bool hasError;
  final bool isChecked;
  final double size;
  final Color? color;
  final Color? checkMarkColor;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeStyle.colors;
    final backColor = color ??
        (hasError
            ? colors.errorInputColor
            : isChecked
                ? colors.activeInputColor
                : colors.inactiveInputColor);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: backColor),
        color: fill ? backColor : null,
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              color: checkMarkColor ?? colors.activeInputColor,
              size: size - 2,
            )
          : null,
    );
  }
}
