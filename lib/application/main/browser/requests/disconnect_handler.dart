import 'dart:async';

import 'package:ever_wallet/application/main/browser/events/models/permissions_changed_event.dart';
import 'package:ever_wallet/application/main/browser/events/permissions_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> disconnectHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required int tabId,
  required PermissionsRepository permissionsRepository,
  required GenericContractsRepository genericContractsRepository,
}) async {
  try {
    logger.d('disconnect', args);

    final origin = await controller.getOrigin();

    await permissionsRepository.deletePermissionsForOrigin(origin);
    await genericContractsRepository.unsubscribeTab(tabId);

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
