import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TokenAssetIcon extends StatelessWidget {
  final String logoURI;

  const TokenAssetIcon({
    Key? key,
    required this.logoURI,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SvgPicture.network(
          logoURI,
          width: 36,
          height: 36,
        ),
      );
}
