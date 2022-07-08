import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/preferences_modal/preferences_modal.dart';
import 'package:flutter/material.dart';

Future<void> showPreferencesModal({
  required BuildContext context,
  required String address,
  String? publicKey,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => PreferencesModalBody(
        address: address,
        publicKey: publicKey,
      ),
    );
