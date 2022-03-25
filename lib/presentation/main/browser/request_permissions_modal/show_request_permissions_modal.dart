import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'request_permissions_modal.dart';

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
