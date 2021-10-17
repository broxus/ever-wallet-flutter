import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../logger.dart';
import 'controller_extensions.dart';

Future<dynamic> codeToTvcHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST codeToTvc args $jsonInput');

    final input = CodeToTvcInput.fromJson(jsonInput);

    final output = await codeToTvc(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST codeToTvc result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> decodeEventHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST decodeEvent args $jsonInput');

    final input = DecodeEventInput.fromJson(jsonInput);

    final output = await decodeEvent(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());
    logger.d('REQUEST decodeEvent result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> decodeInputHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST decodeInput args $jsonInput');

    final input = DecodeInputInput.fromJson(jsonInput);

    final output = await decodeInput(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());
    logger.d('REQUEST decodeInput result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> decodeOutputHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST decodeOutput args $jsonInput');

    final input = DecodeOutputInput.fromJson(jsonInput);

    final output = await decodeOutput(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());
    logger.d('REQUEST decodeOutput result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> decodeTransactionEventsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST decodeTransactionEvents args $jsonInput');

    final input = DecodeTransactionEventsInput.fromJson(jsonInput);

    final output = await decodeTransactionEvents(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST decodeTransactionEvents result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> decodeTransactionHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST decodeTransaction args $jsonInput');

    final input = DecodeTransactionInput.fromJson(jsonInput);

    final output = await decodeTransaction(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());
    logger.d('REQUEST decodeTransaction result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> disconnectHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    await disconnect(
      origin: (await controller.getCurrentOrigin())!,
    );

    final jsonOutput = jsonEncode({});
    logger.d('REQUEST disconnect result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> encodeInternalInputHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST encodeInternalInput args $jsonInput');

    final input = EncodeInternalInputInput.fromJson(jsonInput);

    final output = await encodeInternalInput(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST encodeInternalInput result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> estimateFeesHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST estimateFees args $jsonInput');

    final input = EstimateFeesInput.fromJson(jsonInput);

    final output = await estimateFees(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST estimateFees result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> extractPublicKeyHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST extractPublicKey args $jsonInput');

    final input = ExtractPublicKeyInput.fromJson(jsonInput);

    final output = await extractPublicKey(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST extractPublicKey result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> getExpectedAddressHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST getExpectedAddress args $jsonInput');

    final input = GetExpectedAddressInput.fromJson(jsonInput);

    final output = await getExpectedAddress(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST getExpectedAddress result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> getFullContractStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST getFullContractState args $jsonInput');

    final input = GetFullContractStateInput.fromJson(jsonInput);

    final output = await getFullContractState(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST getFullContractState result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> getProviderStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final output = await getProviderState(
      origin: (await controller.getCurrentOrigin())!,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST getProviderState result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> getTransactionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST getTransactions args $jsonInput');

    final input = GetTransactionsInput.fromJson(jsonInput);

    final output = await getTransactions(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST getTransactions result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> packIntoCellHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST packIntoCell args $jsonInput');

    final input = PackIntoCellInput.fromJson(jsonInput);

    final output = await packIntoCell(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST packIntoCell result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> requestPermissionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST requestPermissions args $jsonInput');

    final input = RequestPermissionsInput.fromJson(jsonInput);

    final output = await requestPermissions(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST requestPermissions result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> runLocalHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST runLocal args $jsonInput');

    final input = RunLocalInput.fromJson(jsonInput);

    final output = await runLocal(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST runLocal result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> sendExternalMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST sendExternalMessage args $jsonInput');

    final input = SendExternalMessageInput.fromJson(jsonInput);

    final output = await sendExternalMessage(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST sendExternalMessage result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> sendMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST sendMessage args $jsonInput');

    final input = SendMessageInput.fromJson(jsonInput);

    final output = await sendMessage(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST sendMessage result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> splitTvcHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST splitTvc args $jsonInput');

    final input = SplitTvcInput.fromJson(jsonInput);

    final output = await splitTvc(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST splitTvc result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> subscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST subscribe args $jsonInput');

    final input = SubscribeInput.fromJson(jsonInput);

    final output = await subscribe(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST subscribe result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> unpackFromCellHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST unpackFromCell args $jsonInput');

    final input = UnpackFromCellInput.fromJson(jsonInput);

    final output = await unpackFromCell(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());
    logger.d('REQUEST unpackFromCell result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> unsubscribeAllHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    await unsubscribeAll(
      origin: (await controller.getCurrentOrigin())!,
    );

    final jsonOutput = jsonEncode({});
    logger.d('REQUEST unsubscribeAll result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}

Future<dynamic> unsubscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;
    logger.d('REQUEST unsubscribe args $jsonInput');

    final input = UnsubscribeInput.fromJson(jsonInput);

    await unsubscribe(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode({});
    logger.d('REQUEST unsubscribe result $jsonOutput');

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
