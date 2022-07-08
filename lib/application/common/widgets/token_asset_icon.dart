import 'package:ever_wallet/application/common/widgets/token_asset_old_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TokenAssetIcon extends StatelessWidget {
  final String logoURI;
  final TokenWalletVersion version;

  const TokenAssetIcon({
    Key? key,
    required this.logoURI,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 36,
        child: Stack(
          children: [
            ClipOval(
              child: SvgPicture.network(
                logoURI,
                width: 36,
                height: 36,
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
