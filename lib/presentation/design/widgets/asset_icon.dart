import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetIcon extends StatelessWidget {
  final String? svgIcon;
  final List<int>? gravatarIcon;
  final double size;

  const AssetIcon({
    Key? key,
    this.svgIcon,
    this.gravatarIcon,
    this.size = 36,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final Widget icon;

    if (svgIcon != null) {
      icon = SvgPicture.string(svgIcon!);
    } else if (gravatarIcon != null) {
      icon = Image.memory(Uint8List.fromList(gravatarIcon!));
    } else {
      icon = const SizedBox();
    }

    return SizedBox.square(
      dimension: size,
      child: ClipOval(child: icon),
    );
  }
}
