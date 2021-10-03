import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../design/design.dart';

Future<void> showApprovalDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: AnimatedPadding(
        duration: kThemeAnimationDuration,
        padding: context.keyboardInsets,
        child: Theme(
          data: ThemeData(),
          child: PlatformAlertDialog(
            title: Text(LocaleKeys.add_site_dialog_title.tr()),
            cupertino: (_, __) => CupertinoAlertDialogData(
              content: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CupertinoTextField(
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            material: (_, __) => MaterialAlertDialogData(
              content: TextField(
                autofocus: true,
              ),
            ),
            actions: [
              PlatformDialogAction(
                onPressed: Navigator.of(context).pop,
                child: Text(LocaleKeys.actions_cancel.tr()),
              ),
              PlatformDialogAction(
                onPressed: Navigator.of(context).pop,
                cupertino: (_, __) => CupertinoDialogActionData(
                  isDefaultAction: true,
                ),
                child: Text(LocaleKeys.add_site_dialog_actions_add.tr()),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
