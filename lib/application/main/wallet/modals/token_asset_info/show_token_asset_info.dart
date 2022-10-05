import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_asset_info/token_asset_info_modal_body.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showTokenAssetInfo({
  required BuildContext context,
  required String owner,
  required String rootTokenContract,
  required String name,
  required String symbol,
  required int decimals,
  required TokenWalletVersion version,
  String? logoURI,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TokenAssetInfoModalBody(
        owner: owner,
        rootTokenContract: rootTokenContract,
        name: name,
        symbol: symbol,
        decimals: decimals,
        version: version,
        logoURI: logoURI,
      ),
    );
