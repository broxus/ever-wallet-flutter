import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool? value;
  final void Function(bool?)? onChanged;

  const CustomCheckbox({
    super.key,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: CrystalColor.accent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        side: MaterialStateBorderSide.resolveWith(
          (states) {
            const side = BorderSide(width: 0.5);

            if (states.contains(MaterialState.selected)) {
              return side.copyWith(color: CrystalColor.accent);
            }

            return side;
          },
        ),
      );
}
