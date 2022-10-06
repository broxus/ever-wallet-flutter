import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../../../generated/assets.gen.dart';
import '../../../providers/common/network_type_provider.dart';

class TonAssetIcon extends StatelessWidget {
  const TonAssetIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final icon = ref.watch(networkTypeProvider).asData?.value == 'Ever'
              ? Assets.images.ever
              : Assets.images.venom;

          return ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: ScalableImageWidget.fromSISource(
                si: ScalableImageSource.fromSvg(rootBundle, icon.path),
              ),
            ),
          );
        },
      );
}
