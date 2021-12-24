import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TokenAssetIcon extends StatelessWidget {
  final String icon;

  const TokenAssetIcon({
    Key? key,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SvgPicture.string(
          icon,
          width: 36,
          height: 36,
        ),
      );
}
