import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CustomCloseButton extends StatelessWidget {
  final void Function()? onPressed;

  const CustomCloseButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PlatformWidget(
        cupertino: (_, __) => CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed ?? Navigator.of(context).pop,
          child: const Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
        material: (_, __) => IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed ?? Navigator.of(context).pop,
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
      );
}
