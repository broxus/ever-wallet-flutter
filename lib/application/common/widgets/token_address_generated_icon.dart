import 'package:ever_wallet/application/common/widgets/address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/token_asset_old_label.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TokenAddressGeneratedIcon extends StatelessWidget {
  final String address;
  final TokenWalletVersion version;

  const TokenAddressGeneratedIcon({
    super.key,
    required this.address,
    required this.version,
  });

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 36,
        child: Stack(
          children: [
            AddressGeneratedIcon(
              address: address,
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
