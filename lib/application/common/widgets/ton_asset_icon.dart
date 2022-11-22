import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TonAssetIcon extends StatelessWidget {
  const TonAssetIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) => TransportTypeBuilderWidget(
        builder: (context, isEver) {
          final icon = isEver ? Assets.images.ever : Assets.images.venom;

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
