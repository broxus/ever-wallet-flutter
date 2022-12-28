import 'package:ever_wallet/application/common/widgets/token_asset_old_label.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TokenAssetIcon extends StatelessWidget {
  final String logoURI;
  final TokenWalletVersion version;

  const TokenAssetIcon({
    super.key,
    required this.logoURI,
    required this.version,
  });

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 36,
        child: Stack(
          children: [
            ClipOval(
              child: ScalableImageWidget.fromSISource(
                si: ScalableImageSource.fromSvgHttpUrl(
                  Uri.parse(
                    logoURI,
                  ),
                ),
              ),
            ),
            if (version == TokenWalletVersion.oldTip3v4)
              const Align(
                alignment: Alignment.bottomRight,
                child: TokenAssetOldLabel(),
              ),
          ],
        ),
      );
}
