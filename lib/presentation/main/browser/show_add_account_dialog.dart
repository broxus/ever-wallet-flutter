import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../generated/codegen_loader.g.dart';
import '../wallet/modals/add_account_flow/start_add_account_flow.dart';

Future<void> showAddAccountDialog({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PlatformAlertDialog(
        title: Text(LocaleKeys.add_account.tr()),
        content: Text(LocaleKeys.browser_add_account_description.tr()),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop(),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          PlatformDialogAction(
            onPressed: () async {
              await context.router.pop();

              startAddAccountFlow(
                context: context,
                publicKey: publicKey,
              );
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: Text(LocaleKeys.add_account.tr()),
          ),
        ],
      ),
    );
