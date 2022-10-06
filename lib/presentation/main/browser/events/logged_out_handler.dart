import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';

Future<void> loggedOutHandler({
  required InAppWebViewController controller,
}) async {
  try {
    logger.d('LoggedOutEvent');

    await controller.evaluateJavascript(source: 'window.__dartNotifications.loggedOut({})');
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
