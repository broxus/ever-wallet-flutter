import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SelectableButton extends StatelessWidget {
  final SvgGenImage icon;
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;

  const SelectableButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => PushStateInkWidget(
        onPressed: onPressed,
        child: container(),
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
          const Gap(16),
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
