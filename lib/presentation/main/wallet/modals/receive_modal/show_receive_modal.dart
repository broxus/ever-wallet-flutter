import 'package:flutter/material.dart';

import '../../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'receive_modal.dart';

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
