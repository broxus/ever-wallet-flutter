import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/models/permission.dart';
import '../events/models/permissions_changed_event.dart';
import '../events/permissions_changed_handler.dart';
import '../extensions.dart';

Future<Map<String, dynamic>> changeAccountHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('changeAccount', args);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    final existingPermissionsList = [
      if (existingPermissions?.basic == null) Permission.basic,
      if (existingPermissions?.accountInteraction == null) Permission.accountInteraction,
    ];

    final permissions = await getIt.get<ApprovalsRepository>().changeAccount(
          origin: origin,
          permissions: existingPermissionsList,
        );

    await getIt.get<PermissionsRepository>().setPermissions(
          origin: origin,
          permissions: permissions,
        );

    final event = PermissionsChangedEvent(permissions: permissions);

    await permissionsChangedHandler(
      controller: controller,
      event: event,
    );

    final jsonOutput = permissions.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('changeAccount', err, st);
    rethrow;
  }
}
