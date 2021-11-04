import 'package:flutter/material.dart';

import '../router.gr.dart';
import 'design.dart';

double getKeyboardInsetsBottom(BuildContext context) {
  final double _keyboardInsetsBottom = context.keyboardInsets.bottom;

  if (context.router.root.current.name == MainRouterRoute.name) {
    return _keyboardInsetsBottom - kBottomBarHeight;
  }

  return _keyboardInsetsBottom;
}

String formatValue(String value) {
  final regex = RegExp(r"([.]*0+)(?!.*\d)");
  final res = value.replaceAll(regex, '');

  String addSpaces(String string) => string.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]} ',
      );

  if (res.contains(".")) {
    final values = res.split(".");
    final firstPart = addSpaces(values.first);
    final lastPart = values.last;

    return [firstPart, lastPart].join(".");
  } else {
    return addSpaces(res);
  }
}
