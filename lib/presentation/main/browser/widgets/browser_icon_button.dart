import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../common/theme.dart';

class BrowserIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const BrowserIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PlatformWidget(
        cupertino: (_, __) => CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Icon(
            icon,
            color: onPressed != null ? CrystalColor.accent : CrystalColor.hintColor,
          ),
        ),
        material: (_, __) => RawMaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(),
          onPressed: onPressed,
          child: Icon(
            icon,
            color: onPressed != null ? CrystalColor.accent : CrystalColor.hintColor,
          ),
        ),
      );
}
