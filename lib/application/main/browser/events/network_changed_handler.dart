import 'dart:async';
import 'dart:convert';

import 'package:ever_wallet/application/main/browser/events/models/network_changed_event.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<void> networkChangedHandler({
  required InAppWebViewController controller,
  required NetworkChangedEvent event,
}) async {
  try {
    logger.d('NetworkChangedEvent', event);

    final jsonOutput = jsonEncode(event.toJson());

    await controller.evaluateJavascript(
      source: "window.__dartNotifications.networkChanged('$jsonOutput')",
    );
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
