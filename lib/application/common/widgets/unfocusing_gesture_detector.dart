import 'package:flutter/material.dart';

class UnfocusingGestureDetector extends StatelessWidget {
  final Widget child;

  const UnfocusingGestureDetector({
    super.key,
    required this.child,
  });

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
