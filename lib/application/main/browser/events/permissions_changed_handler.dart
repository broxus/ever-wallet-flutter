import 'dart:async';
import 'dart:convert';

import 'package:ever_wallet/application/main/browser/events/models/permissions_changed_event.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<void> permissionsChangedHandler({
  required InAppWebViewController controller,
  required PermissionsChangedEvent event,
}) async {
  try {
    logger.d('PermissionsChangedEvent', event);

    final jsonOutput = jsonEncode(event.toJson()).replaceAll('tonClient', 'basic');

    await controller.evaluateJavascript(
      source: "window.__dartNotifications.permissionsChanged('$jsonOutput')",
    );
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
