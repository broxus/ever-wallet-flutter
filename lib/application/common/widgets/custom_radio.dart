import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';

class CustomRadio<T> extends StatelessWidget {
  final T? value;
  final T? groupValue;
  final void Function(T?)? onChanged;

  const CustomRadio({
    super.key,
    this.value,
    this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Radio<T?>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: CrystalColor.accent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      );
}
