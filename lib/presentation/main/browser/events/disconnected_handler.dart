import 'dart:async';

import '../../../../../../../../logger.dart';
import '../custom_in_app_web_view_controller.dart';

Future<void> disconnectedHandler({
  required CustomInAppWebViewController controller,
}) async {
  try {
    await controller.evaluateJavascript(source: 'window.__dartNotifications.disconnected()');
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
