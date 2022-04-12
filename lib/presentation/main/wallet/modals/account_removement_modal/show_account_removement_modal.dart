import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../generated/codegen_loader.g.dart';

Future<void> showAccountRemovementDialog({
  required BuildContext context,
  required String address,
  required void Function() onDeletePressed,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: Text(LocaleKeys.remove_account.tr()),
        content: Text(LocaleKeys.remove_account_confirmation.tr()),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop(),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          PlatformDialogAction(
            onPressed: () {
              onDeletePressed();
              context.router.pop();
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: Text(LocaleKeys.ok.tr()),
          ),
        ],
      ),
    );
