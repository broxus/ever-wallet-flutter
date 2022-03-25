import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../generated/assets.gen.dart';
import '../theme.dart';

class SelectableButton extends StatelessWidget {
  final SvgGenImage icon;
  final String text;
  final void Function() onPressed;
  final bool isSelected;

  const SelectableButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PlatformWidget(
        cupertino: (_, __) => CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.zero,
          onPressed: onPressed,
          child: container(),
        ),
        material: (_, __) => RawMaterialButton(
          onPressed: onPressed,
          child: container(),
        ),
      );

  Widget container() => AnimatedContainer(
        height: 120,
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? CrystalColor.accent.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? CrystalColor.accent.withOpacity(0.3) : Colors.black12,
            width: 1.5,
          ),
        ),
        child: body(),
      );

  Widget body() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image(),
          const SizedBox(height: 16),
          subtitle(),
        ],
      );

  Widget image() => icon.svg(
        color: isSelected ? CrystalColor.accent : Colors.grey,
      );

  Widget subtitle() => Text(
        text,
        style: TextStyle(
          color: isSelected ? CrystalColor.accent : Colors.grey,
          fontSize: 16,
        ),
      );
}
