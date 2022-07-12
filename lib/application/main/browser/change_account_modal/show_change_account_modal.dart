import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/browser/change_account_modal/change_account_page.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:flutter/material.dart';

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
