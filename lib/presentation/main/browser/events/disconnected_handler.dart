import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';

Future<void> disconnectedHandler({
  required InAppWebViewController controller,
}) async {
  try {
    logger.d('DisconnectedEvent');

    await controller.evaluateJavascript(source: 'window.__dartNotifications.disconnected({})');
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
