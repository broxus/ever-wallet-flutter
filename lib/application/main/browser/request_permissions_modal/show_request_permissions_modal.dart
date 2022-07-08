import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/browser/request_permissions_modal/request_permissions_modal.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:flutter/material.dart';

Future<Permissions?> showRequestPermissionsModal({
  required BuildContext context,
  required String origin,
  required List<Permission> permissions,
}) =>
    showPlatformModalBottomSheet<Permissions>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => RequestPermissionsPage(
            modalContext: context,
            origin: origin,
            permissions: permissions,
          ),
        ),
      ),
    );
