import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_asset_modal/add_asset_modal_body.dart';
import 'package:flutter/material.dart';

Future<void> showAddAssetModal({
  required BuildContext context,
  required String address,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => AddAssetModalBody(
        address: address,
      ),
    );
