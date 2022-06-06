import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../wallet/modals/add_account_flow/start_add_account_flow.dart';

Future<void> showAddAccountDialog({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PlatformAlertDialog(
        title: Text(AppLocalizations.of(context)!.add_account),
        content: Text(AppLocalizations.of(context)!.browser_add_account_description),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.add_account),
          ),
        ],
      ),
    );
