import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BrowserIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;

  const BrowserIconButton({
    Key? key,
    required this.onPressed,
    this.icon,
    this.child,
  })  : assert(icon == null && child != null || icon != null && child == null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryIconButton(
      icon: child ??
          Icon(
            icon,
            color: onPressed == null ? ColorsRes.neutral500 : ColorsRes.bluePrimary400,
            size: 24,
          ),
      onPressed: onPressed,
      outerPadding: EdgeInsets.zero,
    );
  }
}
