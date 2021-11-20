import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).appBarTheme.iconTheme?.color;

    return PlatformWidget(
      cupertino: (_, __) => CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
        onPressed: () => Navigator.maybePop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios,
              color: color,
            ),
            Text(
              'Back',
              style: Theme.of(context).textTheme.button?.copyWith(color: color),
            ),
          ],
        ),
      ),
      material: (_, __) => IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: () => Navigator.maybePop(context),
        icon: Icon(
          Icons.arrow_back,
          color: color,
        ),
      ),
    );
  }
}
