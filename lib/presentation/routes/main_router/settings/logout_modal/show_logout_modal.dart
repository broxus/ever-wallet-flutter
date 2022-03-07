import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/common/application_flow_provider.dart';
import '../../../../design/design.dart';

Future<void> showLogoutDialog({
  required BuildContext context,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Consumer(
        builder: (context, ref, child) => PlatformAlertDialog(
          title: Text(LocaleKeys.settings_screen_sections_logout_confirmation.tr()),
          actions: [
            PlatformDialogAction(
              onPressed: context.router.pop,
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: true,
              ),
              child: Text(LocaleKeys.actions_cancel.tr()),
            ),
            PlatformDialogAction(
              onPressed: () {
                ref.read(applicationFlowProvider.notifier).logOut();
                context.router.pop();
              },
              cupertino: (_, __) => CupertinoDialogActionData(
                isDestructiveAction: true,
              ),
              child: Text(LocaleKeys.settings_screen_sections_logout_action.tr()),
            ),
          ],
        ),
      ),
    );
