import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../logger.dart';

Future<void> disconnectedCaller({
  required InAppWebViewController controller,
  required Error event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson());
    logger.d('EVENT disconnected $jsonOutput');

    await controller.evaluateJavascript(source: "window.__dartNotifications.disconnected('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<void> transactionsFoundCaller({
  required InAppWebViewController controller,
  required TransactionsFoundEvent event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson());
    logger.d('EVENT transactionsFound $jsonOutput');

    await controller.evaluateJavascript(source: "window.__dartNotifications.transactionsFound('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<void> contractStateChangedCaller({
  required InAppWebViewController controller,
  required ContractStateChangedEvent event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson());
    logger.d('EVENT contractStateChanged $jsonOutput');

    await controller.evaluateJavascript(source: "window.__dartNotifications.contractStateChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<void> networkChangedCaller({
  required InAppWebViewController controller,
  required NetworkChangedEvent event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson());
    logger.d('EVENT networkChanged $jsonOutput');

    await controller.evaluateJavascript(source: "window.__dartNotifications.networkChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<void> permissionsChangedCaller({
  required InAppWebViewController controller,
  required PermissionsChangedEvent event,
}) async {
  try {
    final jsonOutput = jsonEncode(event.toJson());
    logger.d('EVENT permissionsChanged $jsonOutput');

    await controller.evaluateJavascript(source: "window.__dartNotifications.permissionsChanged('$jsonOutput')");
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<void> loggedOutCaller({
  required InAppWebViewController controller,
  required Object event,
}) async {
  try {
    logger.d('EVENT loggedOut');

    await controller.evaluateJavascript(source: 'window.__dartNotifications.loggedOut()');
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
