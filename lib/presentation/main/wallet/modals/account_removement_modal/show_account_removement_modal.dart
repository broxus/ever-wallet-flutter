import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<void> showAccountRemovementDialog({
  required BuildContext context,
  required String address,
  required void Function() onDeletePressed,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: Text(AppLocalizations.of(context)!.remove_account),
        content: Text(AppLocalizations.of(context)!.remove_account_confirmation),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop(),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          PlatformDialogAction(
            onPressed: () {
              onDeletePressed();
              context.router.pop();
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
