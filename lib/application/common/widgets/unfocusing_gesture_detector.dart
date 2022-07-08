import 'package:flutter/material.dart';

class UnfocusingGestureDetector extends StatelessWidget {
  final Widget child;

  const UnfocusingGestureDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          final focusScope = FocusScope.of(context);

          if (focusScope.hasFocus) {
            focusScope.unfocus();
          }
        },
        child: child,
      );
}
