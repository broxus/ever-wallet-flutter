import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../generated/codegen_loader.g.dart';

Future<void> showKeyRemovementDialog({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: Text(LocaleKeys.remove_key.tr()),
        content: Text(LocaleKeys.remove_key_confirmation.tr()),
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
              getIt.get<KeysRepository>().removeKey(publicKey);

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