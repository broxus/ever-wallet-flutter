import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/blocs/key/current_key_provider.dart';
import '../../design/design.dart';
import 'wallet/modals/add_account_flow/start_add_account_flow.dart';

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
          Consumer(
            builder: (context, ref, child) => PlatformDialogAction(
              onPressed: () async {
                final currentKey = await ref.read(currentKeyProvider.future);

                await context.router.pop();

                if (currentKey == null) return;

                startAddAccountFlow(
                  context: context,
                  publicKey: currentKey.publicKey,
                );
              },
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: true,
              ),
              child: const Text('Add account'),
            ),
          ),
        ],
      ),
    );
