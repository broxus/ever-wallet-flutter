import 'dart:async';

import '../../../../../../../../logger.dart';
import '../custom_in_app_web_view_controller.dart';

Future<void> loggedOutHandler({
  required CustomInAppWebViewController controller,
}) async {
  try {
    await controller.evaluateJavascript(source: 'window.__dartNotifications.loggedOut()');
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
