import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'address_generated_icon.dart';
import 'token_asset_old_label.dart';

class TokenAddressGeneratedIcon extends StatelessWidget {
  final String address;
  final TokenWalletVersion version;

  const TokenAddressGeneratedIcon({
    Key? key,
    required this.address,
    required this.version,
  }) : super(key: key);

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
