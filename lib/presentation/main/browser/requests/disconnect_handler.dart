import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/models/permissions.dart';
import '../events/models/permissions_changed_event.dart';
import '../events/permissions_changed_handler.dart';
import '../extensions.dart';

Future<Map<String, dynamic>> disconnectHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('disconnect', args);

    final origin = await controller.getOrigin();

    await getIt.get<PermissionsRepository>().deletePermissionsForOrigin(origin);
    getIt.get<GenericContractsRepository>().clear();

    const event = PermissionsChangedEvent(permissions: Permissions());

    await permissionsChangedHandler(
      controller: controller,
      event: event,
    );

    final jsonOutput = <String, dynamic>{};

    return jsonOutput;
  } catch (err, st) {
    logger.e('disconnect', err, st);
    rethrow;
  }
}
