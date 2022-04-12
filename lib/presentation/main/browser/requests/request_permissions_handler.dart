import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../events/permissions_changed_handler.dart';
import '../extensions.dart';

Future<dynamic> requestPermissionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('RequestPermissionsRequest', args);

    final jsonInput = jsonDecode(jsonEncode(args.first as Map<String, dynamic>).replaceAll('tonClient', 'basic'))
        as Map<String, dynamic>;

    final input = RequestPermissionsInput.fromJson(jsonInput);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    late Permissions requested;

    try {
      requested = await getIt.get<PermissionsRepository>().checkPermissions(
            origin: currentOrigin,
            requiredPermissions: input.permissions,
          );
    } catch (_) {
      requested = await getIt.get<ApprovalsRepository>().requestForPermissions(
            origin: currentOrigin,
            permissions: input.permissions,
          );

      await getIt.get<PermissionsRepository>().setPermissions(
            origin: currentOrigin,
            permissions: requested,
          );
    }

    final event = PermissionsChangedEvent(permissions: requested);

    await permissionsChangedHandler(
      controller: controller,
      event: event,
    );

    final output = requested;

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
