import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'add_account_page.dart';

Future<void> startAddAccountFlow({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 525,
        child: Navigator(
          initialRoute: '/',
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => AddAccountPage(
              modalContext: context,
              publicKey: publicKey,
            ),
          ),
        ),
      ),
    );
