import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetIcon extends StatefulWidget {
  final String? svgIcon;
  final List<int>? gravatarIcon;

  const AssetIcon({
    Key? key,
    this.svgIcon,
    this.gravatarIcon,
  }) : super(key: key);

  @override
  _AssetIconState createState() => _AssetIconState();
}

class _AssetIconState extends State<AssetIcon> {
  late final Widget icon;

  @override
  void initState() {
    super.initState();
    if (widget.svgIcon != null) {
      icon = SvgPicture.string(widget.svgIcon!);
    } else if (widget.gravatarIcon != null) {
      icon = Image.memory(Uint8List.fromList(widget.gravatarIcon!));
    } else {
      icon = const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) => ClipOval(child: icon);
}
