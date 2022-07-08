import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_asset_info/ton_asset_info_modal_body.dart';
import 'package:flutter/material.dart';

Future<void> showTonAssetInfo({
  required BuildContext context,
  required String address,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonAssetInfoModalBody(
        address: address,
      ),
    );
