import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../design/design.dart';
import '../router.gr.dart';

Future<void> showAddAccountDialog({
  required BuildContext context,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: const Text('Add account'),
        content: const Text('To use the browser you need to add an account first'),
        actions: [
          PlatformDialogAction(
            onPressed: () => context.router.pop(),
            child: const Text('Cancel'),
          ),
          PlatformDialogAction(
            onPressed: () async {
              await context.router.pop();

              final mainRouterRouter = context.router.root.innerRouterOf(MainRouterRoute.name);
              final walletRouterRouter = mainRouterRouter?.innerRouterOf(WalletRouterRoute.name);

              mainRouterRouter?.navigate(const WalletRouterRoute());
              walletRouterRouter?.navigate(const NewAccountRouterRoute());
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: const Text('Add account'),
          ),
        ],
      ),
    );
