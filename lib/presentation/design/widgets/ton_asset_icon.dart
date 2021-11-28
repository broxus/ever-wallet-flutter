import 'package:flutter/material.dart';

import '../design.dart';

class TonAssetIcon extends StatelessWidget {
  final double size;

  const TonAssetIcon({
    Key? key,
    this.size = 36,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Assets.images.ton.svg(
        width: size,
        height: size,
      );
}
