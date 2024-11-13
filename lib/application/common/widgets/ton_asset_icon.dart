import 'package:ever_wallet/application/common/widgets/transport_builder.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TonAssetIcon extends StatelessWidget {
  const TonAssetIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) => TransportBuilderWidget(
        builder: (context, data) {
          final icon = data.type.when(
            everscale: () => Assets.images.ever,
            venom: () => Assets.images.venom,
            tycho: () => Assets.images.tycho,
          );

          return ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: SvgPicture.asset(
                icon.path,
                width: 36,
                height: 36,
              ),
            ),
          );
        },
      );
}
