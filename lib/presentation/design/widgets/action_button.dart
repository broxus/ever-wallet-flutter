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
  Widget build(BuildContext context) => PlatformWidget(
        cupertino: (_, __) => CupertinoButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: Theme.of(context).textTheme.button?.copyWith(
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
          ),
        ),
        material: (_, __) => TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
          ),
        ),
      );
}
