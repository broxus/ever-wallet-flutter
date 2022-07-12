import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<bool?> showConfirmRemoveBookmarkDialog({
  required BuildContext context,
}) =>
    showPlatformDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PlatformAlertDialog(
        title: Text(AppLocalizations.of(context)!.remove_bookmark),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop<bool>(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          PlatformDialogAction(
            onPressed: () async => Navigator.of(context).pop<bool>(true),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
