import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<void> showAccountRemovementDialog({
  required BuildContext context,
  required String address,
  required void Function() onDeletePressed,
}) =>
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: const Text('Remove account'),
        content: const Text('Do you want to remove account from the list?'),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop(),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: const Text('Cancel'),
          ),
          PlatformDialogAction(
            onPressed: () {
              onDeletePressed();
              context.router.pop();
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
