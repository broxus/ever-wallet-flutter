import 'dart:async';
import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../custom_in_app_web_view_controller.dart';

Future<dynamic> requestPermissionsHandler({
  required CustomInAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = jsonDecode(jsonEncode(args.first as Map<String, dynamic>).replaceAll('tonClient', 'basic'))
        as Map<String, dynamic>;

    final input = RequestPermissionsInput.fromJson(jsonInput);

    final currentOrigin = await controller.controller.getUrl().then((v) => v?.authority);

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

    final output = requested;

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
