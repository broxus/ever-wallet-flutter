import 'dart:async';

import 'package:ever_wallet/application/main/browser/events/models/permissions_changed_event.dart';
import 'package:ever_wallet/application/main/browser/events/permissions_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> changeAccountHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
}) async {
  try {
    logger.d('changeAccount', args);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    final existingPermissionsList = [
      if (existingPermissions?.basic == null) Permission.basic,
      if (existingPermissions?.accountInteraction == null) Permission.accountInteraction,
    ];

    final permissions = await approvalsRepository.changeAccount(
      origin: origin,
      permissions: existingPermissionsList,
    );

    await permissionsRepository.setPermissions(
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
