import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:flutter/material.dart';

class MenuDropdownData {
  final String title;
  final Widget? icon;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  MenuDropdownData({
    required this.onTap,
    required this.title,
    this.icon,
    this.textStyle,
  });
}

/// Default button that displays list of menu items without values
class MenuDropdown extends StatelessWidget {
  const MenuDropdown({
    super.key,
    required this.items,
    this.iconColor = ColorsRes.darkBlue,
    this.buttonDecoration,
  });

  final List<MenuDropdownData> items;
  final Color iconColor;
  final BoxDecoration? buttonDecoration;

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return DropdownButton2<int>(
      dropdownDecoration: BoxDecoration(
        color: themeStyle.colors.secondaryBackgroundColor,
      ),
      items: items.mapIndex((v, index) {
        return DropdownMenuItem(
          value: index,
          onTap: v.onTap,
          child: Text(
            v.title,
            style: v.textStyle ?? themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
        );
      }).toList(),
      customButton: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.more_horiz, color: iconColor, size: 20),
      ),
      dropdownWidth: 200,
      buttonDecoration: buttonDecoration ?? BoxDecoration(borderRadius: BorderRadius.circular(90)),
      underline: const SizedBox.shrink(),
      onChanged: (_) {},
      dropdownElevation: 6,
    );
  }
}
