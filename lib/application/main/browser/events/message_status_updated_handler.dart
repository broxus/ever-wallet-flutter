import 'dart:async';
import 'dart:convert';

import 'package:ever_wallet/application/main/browser/events/models/message_status_updated_event.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<void> messageStatusUpdatedHandler({
  required InAppWebViewController controller,
  required MessageStatusUpdatedEvent event,
}) async {
  try {
    logger.d('MessageStatusUpdatedEvent', event);

    final jsonOutput = jsonEncode(event.toJson());

    await controller.evaluateJavascript(
      source: "window.__dartNotifications.messageStatusUpdated('$jsonOutput')",
    );
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
