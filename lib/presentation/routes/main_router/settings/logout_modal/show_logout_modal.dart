import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../domain/blocs/application_flow_bloc.dart';
import '../../../../design/design.dart';

Future<void> showLogoutDialog({
  required BuildContext context,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
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
              context.read<ApplicationFlowBloc>().add(const ApplicationFlowEvent.logOut());
              context.router.pop();
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: Text(LocaleKeys.settings_screen_sections_logout_action.tr()),
          ),
        ],
      ),
    );
