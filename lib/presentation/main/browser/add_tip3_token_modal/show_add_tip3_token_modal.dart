import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'add_tip3_token_page.dart';

Future<bool?> showAddTip3TokenModal({
  required BuildContext context,
  required String origin,
  required String account,
  required RootTokenContractDetails details,
}) =>
    showPlatformModalBottomSheet<bool>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => AddTip3TokenPage(
            modalContext: context,
            origin: origin,
            account: account,
            details: details,
          ),
        ),
      ),
    );
