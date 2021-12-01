import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_icon_button.dart';

class CustomCloseButton extends StatelessWidget {
  final void Function()? onPressed;

  const CustomCloseButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => CustomIconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.black,
        ),
        onPressed: onPressed ?? Navigator.of(context).pop,
      );
}
