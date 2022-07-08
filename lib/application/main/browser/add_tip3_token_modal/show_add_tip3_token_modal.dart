import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/browser/add_tip3_token_modal/add_tip3_token_page.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

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
