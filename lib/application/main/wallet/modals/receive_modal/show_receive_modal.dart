import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/receive_modal.dart';
import 'package:flutter/material.dart';

Future<void> showReceiveModal({
  required BuildContext context,
  required String address,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => ReceiveModalBody(
        address: address,
      ),
    );
