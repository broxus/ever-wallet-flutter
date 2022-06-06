import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';

Future<void> showKeyRemovementDialog({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: Text(AppLocalizations.of(context)!.remove_key),
        content: Text(AppLocalizations.of(context)!.remove_key_confirmation),
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
              getIt.get<KeysRepository>().removeKey(publicKey);

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
