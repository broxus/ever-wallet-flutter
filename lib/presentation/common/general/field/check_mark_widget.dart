import 'package:flutter/material.dart';

import '../../../util/extensions/context_extensions.dart';

/// Mark for checkbox with 3 states
class CheckMarkWidget extends StatelessWidget {
  const CheckMarkWidget({
    Key? key,
    this.size = 18,
    this.hasError = false,
    this.isChecked = false,
    this.color,
  }) : super(key: key);

  final bool hasError;
  final bool isChecked;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeStyle.colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: color ??
              (hasError
                  ? colors.errorInputColor
                  : isChecked
                      ? colors.activeInputColor
                      : colors.inactiveInputColor),
        ),
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              color: colors.activeInputColor,
              size: size - 2,
            )
          : null,
    );
  }
}
