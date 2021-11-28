import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CustomInkWell extends StatelessWidget {
  final void Function()? onTap;
  final Widget child;

  const CustomInkWell({
    Key? key,
    this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PlatformWidget(
        cupertino: (context, platform) => InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          child: child,
        ),
        material: (context, platform) => InkWell(
          onTap: onTap,
          child: child,
        ),
      );
}
