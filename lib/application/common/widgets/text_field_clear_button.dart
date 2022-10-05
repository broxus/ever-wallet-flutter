import 'package:ever_wallet/application/common/widgets/text_suffix_icon_button.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';

class TextFieldClearButton extends StatelessWidget {
  final TextEditingController controller;
  final Color? iconColor;
  final FocusNode? focus;

  const TextFieldClearButton({
    required this.controller,
    this.focus,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: value.text.isNotEmpty ? child! : const SizedBox(),
        ),
        child: SuffixIconButton(
          onPressed: () {
            controller.clear();
            Form.of(context)?.validate();
            focus?.requestFocus();
          },
          icon: Assets.images.iconCross.svg(color: iconColor),
        ),
      );
}
