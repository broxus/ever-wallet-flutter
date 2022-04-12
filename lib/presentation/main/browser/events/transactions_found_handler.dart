import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';

Future<void> transactionsFoundHandler({
  required InAppWebViewController controller,
  required TransactionsFoundEvent event,
}) async {
  try {
    logger.d('TransactionsFoundEvent', event);

    final jsonOutput = jsonEncode(event.toJson());

    await controller.evaluateJavascript(source: "window.__dartNotifications.transactionsFound('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
    rethrow;
  }
}
