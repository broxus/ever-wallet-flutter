import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import 'models/permissions_changed_event.dart';

Future<void> permissionsChangedHandler({
  required InAppWebViewController controller,
  required PermissionsChangedEvent event,
}) async {
  try {
    logger.d('PermissionsChangedEvent', event);

    final jsonOutput = jsonEncode(event.toJson()).replaceAll('tonClient', 'basic');

    await controller.evaluateJavascript(source: "window.__dartNotifications.permissionsChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
