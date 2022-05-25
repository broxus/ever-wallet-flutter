import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/models/permission.dart';
import '../../../../data/models/permissions.dart';
import '../events/models/permissions_changed_event.dart';
import '../events/permissions_changed_handler.dart';
import '../extensions.dart';
import 'models/request_permissions_input.dart';

Future<Map<String, dynamic>> requestPermissionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('requestPermissions', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final fixedJsonInput = jsonDecode(jsonEncode(jsonInput).replaceAll('tonClient', 'basic')) as Map<String, dynamic>;
    final input = RequestPermissionsInput.fromJson(fixedJsonInput);

    final origin = await controller.getOrigin();

    final requiredPermissions = input.permissions;
    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    Permissions permissions;

    if (existingPermissions != null) {
      final newPermissions = [
        if (requiredPermissions.contains(Permission.basic) && existingPermissions.basic == null) Permission.basic,
        if (requiredPermissions.contains(Permission.accountInteraction) &&
            existingPermissions.accountInteraction == null)
          Permission.accountInteraction,
      ];

      if (newPermissions.isNotEmpty) {
        permissions = await getIt.get<ApprovalsRepository>().requestPermissions(
              origin: origin,
              permissions: newPermissions,
            );

        await getIt.get<PermissionsRepository>().setPermissions(
              origin: origin,
              permissions: permissions,
            );
      } else {
        permissions = existingPermissions;
      }
    } else {
      permissions = await getIt.get<ApprovalsRepository>().requestPermissions(
            origin: origin,
            permissions: requiredPermissions,
          );

      await getIt.get<PermissionsRepository>().setPermissions(
            origin: origin,
            permissions: permissions,
          );
    }

    final event = PermissionsChangedEvent(permissions: permissions);

    await permissionsChangedHandler(
      controller: controller,
      event: event,
    );

    final jsonOutput = permissions.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('requestPermissions', err, st);
    rethrow;
  }
}
