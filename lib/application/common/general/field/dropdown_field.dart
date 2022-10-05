import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

const kDropdownHeight = 52.0;

typedef DropdownTitleBuilder<T> = String Function(T value);
typedef DropdownChildBuilder<T> = Widget Function(T value);

class DropdownField<T> extends StatelessWidget {
  final double? height;

  final T value;
  final List<T> values;
  final DropdownTitleBuilder<T>? titleBuilder;
  final DropdownChildBuilder<T>? childBuilder;

  final ValueChanged<T> onValueSelected;

  const DropdownField({
    super.key,
    this.height,
    required this.value,
    required this.values,
    required this.onValueSelected,
    this.titleBuilder,
    this.childBuilder,
  })  :
        // One of builders must not be null
        assert(
          titleBuilder == null && childBuilder != null ||
              titleBuilder != null && childBuilder == null,
        );

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return PushStateInkWidget(
      onPressed: () {},
      child: Container(
        height: height ?? kDropdownHeight,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(
            color: themeStyle.colors.inactiveInputColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: childBuilder != null
                  ? childBuilder!(value)
                  : Text(
                      titleBuilder!(value),
                      style: themeStyle.styles.basicStyle,
                      textAlign: TextAlign.left,
                    ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_drop_down, color: themeStyle.colors.inactiveInputColor),
          ],
        ),
      ),
    );
  }
}
