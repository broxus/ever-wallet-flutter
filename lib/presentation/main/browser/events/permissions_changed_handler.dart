import 'dart:async';
import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../custom_in_app_web_view_controller.dart';

Future<void> permissionsChangedHandler({
  required CustomInAppWebViewController controller,
  required PermissionsChangedEvent event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson()).replaceAll('tonClient', 'basic');

    await controller.evaluateJavascript(source: "window.__dartNotifications.permissionsChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
