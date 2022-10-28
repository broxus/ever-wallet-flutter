import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_account_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_existing_account_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_new_account_name_page.dart';
import 'package:flutter/material.dart';

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

Future<void> startAddLocalAccountFlow({
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
            builder: (_) => AddNewAccountNamePage(
              modalContext: context,
              publicKey: publicKey,
            ),
          ),
        ),
      ),
    );

Future<void> startAddExternalAccountFlow({
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
            builder: (_) => AddExistingAccountPage(
              modalContext: context,
              publicKey: publicKey,
            ),
          ),
        ),
      ),
    );
