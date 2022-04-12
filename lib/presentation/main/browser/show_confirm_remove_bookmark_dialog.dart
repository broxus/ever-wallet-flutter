import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../generated/codegen_loader.g.dart';

Future<bool?> showConfirmRemoveBookmarkDialog({
  required BuildContext context,
}) =>
    showPlatformDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PlatformAlertDialog(
        title: Text(LocaleKeys.remove_bookmark.tr()),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop<bool>(false),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          PlatformDialogAction(
            onPressed: () async => context.router.pop<bool>(true),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: Text(LocaleKeys.ok.tr()),
          ),
        ],
      ),
    );
