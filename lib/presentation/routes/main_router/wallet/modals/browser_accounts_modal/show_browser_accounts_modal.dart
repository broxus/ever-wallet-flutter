import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'browser_accounts_modal.dart';

Future<void> showBrowserAccountsModal({
  required BuildContext context,
  required List<AssetsList> accounts,
  required void Function(String) onTap,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => BrowserAccountsModalBody(
        accounts: accounts,
        onTap: onTap,
      ),
    );
