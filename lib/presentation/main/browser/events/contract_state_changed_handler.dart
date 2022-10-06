import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import 'models/contract_state_changed_event.dart';

Future<void> contractStateChangedHandler({
  required InAppWebViewController controller,
  required ContractStateChangedEvent event,
}) async {
  try {
    logger.d('ContractStateChangedEvent', event);

    final jsonOutput = jsonEncode(event.toJson());

    await controller.evaluateJavascript(source: "window.__dartNotifications.contractStateChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}