import 'package:flutter/material.dart';

import '../design.dart';
import 'text_suffix_icon_button.dart';

class TextFieldClearButton extends StatelessWidget {
  final TextEditingController controller;

  const TextFieldClearButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

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
          },
          icon: Assets.images.iconCross.svg(),
        ),
      );
}
