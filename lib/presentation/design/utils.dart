import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'design.dart';

Widget getRandomTokenAssetIcon(int hashCode) => ClipOval(
      child: Image.network(
        Gravatar('$hashCode@example.com').imageUrl(),
      ),
    );

Widget getTokenAssetIcon(String logoURI) => SvgPicture.network(logoURI);

double getKeyboardInsetsBottom(BuildContext context) {
  final double _keyboardInsetsBottom = context.keyboardInsets.bottom;

  return _keyboardInsetsBottom;
}

String formatValue(String value) {
  final regex = RegExp(r"([.]*0+)(?!.*\d)");
  return value.replaceAll(regex, '');
}
