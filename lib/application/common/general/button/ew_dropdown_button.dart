import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class EWDropdownButton<T> extends StatelessWidget {
  final List<Tuple2<T, String>> items;
  final T? value;
  final void Function(T?) onChanged;

  const EWDropdownButton({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: ColorsRes.greyLight)),
      child: DropdownButton2<T>(
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
                value: e.item1,
                child: Text(
                  e.item2,
                  style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
                ),
              ),
            )
            .toList(),
        value: value,
        onChanged: onChanged,
        style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: ColorsRes.text),
        isExpanded: true,
        offset: Offset.zero,
        dropdownPadding: EdgeInsets.zero,
        buttonDecoration: BoxDecoration(color: themeStyle.colors.secondaryBackgroundColor),
        dropdownDecoration: BoxDecoration(color: themeStyle.colors.secondaryBackgroundColor),
      ),
    );
  }
}
