import 'dart:async';
import 'dart:convert';

import 'package:ever_wallet/application/main/browser/events/models/permissions_changed_event.dart';
import 'package:ever_wallet/application/main/browser/events/permissions_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/request_permissions_input.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> requestPermissionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
}) async {
  try {
    logger.d('requestPermissions', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final fixedJsonInput =
        jsonDecode(jsonEncode(jsonInput).replaceAll('tonClient', 'basic')) as Map<String, dynamic>;
    final input = RequestPermissionsInput.fromJson(fixedJsonInput);

    final origin = await controller.getOrigin();

    final requiredPermissions = input.permissions;
    final existingPermissions = permissionsRepository.permissions[origin];

    Permissions permissions;

    if (existingPermissions != null) {
      final newPermissions = [
        if (requiredPermissions.contains(Permission.basic) && existingPermissions.basic == null)
          Permission.basic,
        if (requiredPermissions.contains(Permission.accountInteraction) &&
            existingPermissions.accountInteraction == null)
          Permission.accountInteraction,
      ];

      if (newPermissions.isNotEmpty) {
        permissions = await approvalsRepository.requestPermissions(
          origin: origin,
          permissions: newPermissions,
        );

        await permissionsRepository.setPermissions(
          origin: origin,
          permissions: permissions,
        );
      } else {
        permissions = existingPermissions;
      }
    } else {
      permissions = await approvalsRepository.requestPermissions(
        origin: origin,
        permissions: requiredPermissions,
      );

      await permissionsRepository.setPermissions(
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
