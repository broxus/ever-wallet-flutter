import 'package:flutter/material.dart';

import '../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'add_external_account_modal.dart';

Future<void> showAddExternalAccountModal({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => AddExternalAccountModalBody(
        publicKey: publicKey,
      ),
    );
