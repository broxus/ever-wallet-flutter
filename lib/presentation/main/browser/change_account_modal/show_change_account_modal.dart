import 'package:flutter/material.dart';

import '../../../../data/models/permission.dart';
import '../../../../data/models/permissions.dart';
import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'change_account_page.dart';

Future<Permissions?> showChangeAccountModal({
  required BuildContext context,
  required List<Permission> permissions,
  required String origin,
}) =>
    showPlatformModalBottomSheet<Permissions>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => ChangeAccountPage(
            modalContext: context,
            permissions: permissions,
            origin: origin,
          ),
        ),
      ),
    );
