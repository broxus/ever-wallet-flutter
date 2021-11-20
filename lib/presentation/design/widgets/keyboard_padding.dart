import 'package:flutter/material.dart';

import '../../design/design.dart';

class KeyboardPadding extends StatelessWidget {
  final Widget child;

  const KeyboardPadding({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottom > kBottomBarHeight ? bottom - kBottomBarHeight : bottom,
      ),
      child: child,
    );
  }
}
