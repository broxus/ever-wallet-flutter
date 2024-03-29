import 'package:ever_wallet/application/common/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final void Function()? onPressed;

  const CustomCloseButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => CustomIconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.black,
        ),
        onPressed: onPressed ?? Navigator.of(context).pop,
      );
}
