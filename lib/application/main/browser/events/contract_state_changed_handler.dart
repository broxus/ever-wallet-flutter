import 'dart:async';
import 'dart:convert';

import 'package:ever_wallet/application/main/browser/events/models/contract_state_changed_event.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<void> contractStateChangedHandler({
  required InAppWebViewController controller,
  required ContractStateChangedEvent event,
}) async {
  try {
    logger.d('ContractStateChangedEvent', event);

    final jsonOutput = jsonEncode(event.toJson());

    await controller.evaluateJavascript(
      source: "window.__dartNotifications.contractStateChanged('$jsonOutput')",
    );
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
