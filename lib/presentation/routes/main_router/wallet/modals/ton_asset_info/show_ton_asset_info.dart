import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'ton_asset_info_modal_body.dart';

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
