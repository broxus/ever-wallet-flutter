import 'dart:async';
import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../custom_in_app_web_view_controller.dart';

Future<void> contractStateChangedHandler({
  required CustomInAppWebViewController controller,
  required ContractStateChangedEvent event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson());

    await controller.evaluateJavascript(source: "window.__dartNotifications.contractStateChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
