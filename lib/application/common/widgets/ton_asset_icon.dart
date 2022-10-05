import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';

class TonAssetIcon extends StatelessWidget {
  const TonAssetIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) => ClipOval(
        child: Assets.images.ever.svg(
          width: 36,
          height: 36,
        ),
      );
}
