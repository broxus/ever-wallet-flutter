import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'add_asset_modal_body.dart';

Future<void> showAddAssetModal({
  required BuildContext context,
  required String address,
  bool isExternal = false,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => AddAssetModalBody(
        address: address,
        isExternal: isExternal,
      ),
    );
