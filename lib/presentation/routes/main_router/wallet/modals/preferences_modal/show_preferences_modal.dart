import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'preferences_modal.dart';

Future<void> showPreferencesModal({
  required BuildContext context,
  required String address,
  bool isExternal = false,
  String? publicKey,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => PreferencesModalBody(
        address: address,
        isExternal: isExternal,
        publicKey: publicKey,
      ),
    );
