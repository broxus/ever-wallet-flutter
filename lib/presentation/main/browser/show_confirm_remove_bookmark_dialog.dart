import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<bool?> showConfirmRemoveBookmarkDialog({
  required BuildContext context,
}) =>
    showPlatformDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Remove bookmark'),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop<bool>(false),
            child: const Text('Cancel'),
          ),
          PlatformDialogAction(
            onPressed: () async => context.router.pop<bool>(true),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
