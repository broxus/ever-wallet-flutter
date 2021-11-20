import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const ActionButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).appBarTheme.iconTheme?.color;

    return PlatformWidget(
      cupertino: (_, __) => CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context).textTheme.button?.copyWith(color: color),
        ),
      ),
      material: (_, __) => TextButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: color,
          ),
        ),
      ),
    );
  }
}
