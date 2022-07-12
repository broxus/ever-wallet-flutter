import 'package:ever_wallet/application/common/general/field/check_mark_widget.dart';
import 'package:flutter/material.dart';

class CheckboxInputField extends StatelessWidget {
  final Widget text;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool? hasError;
  final EdgeInsets? padding;

  final bool needValidation;

  const CheckboxInputField({
    required this.text,
    required this.value,
    required this.onChanged,
    this.padding,
    this.hasError,
    this.needValidation = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: FormField<bool>(
        initialValue: value,
        validator: !needValidation ? null : (_) => !value ? '' : null,
        builder: (field) {
          return Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CheckMarkWidget(isChecked: value, hasError: hasError ?? field.hasError),
                ),
                const SizedBox(width: 16),
                Flexible(child: text),
              ],
            ),
          );
        },
      ),
    );
  }
}
