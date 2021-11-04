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

    final input = CodeToTvcInput.fromJson(jsonInput);

    final output = await codeToTvc(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = DecodeEventInput.fromJson(jsonInput);

    final output = await decodeEvent(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());

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

    final input = DecodeInputInput.fromJson(jsonInput);

    final output = await decodeInput(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());

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

    final input = DecodeOutputInput.fromJson(jsonInput);

    final output = await decodeOutput(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());

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

    final input = DecodeTransactionEventsInput.fromJson(jsonInput);

    final output = await decodeTransactionEvents(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = DecodeTransactionInput.fromJson(jsonInput);

    final output = await decodeTransaction(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output?.toJson());

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

    final input = EncodeInternalInputInput.fromJson(jsonInput);

    final output = await encodeInternalInput(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = EstimateFeesInput.fromJson(jsonInput);

    final output = await estimateFees(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = ExtractPublicKeyInput.fromJson(jsonInput);

    final output = await extractPublicKey(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = GetExpectedAddressInput.fromJson(jsonInput);

    final output = await getExpectedAddress(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = GetFullContractStateInput.fromJson(jsonInput);

    final output = await getFullContractState(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = GetTransactionsInput.fromJson(jsonInput);

    final output = await getTransactions(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = PackIntoCellInput.fromJson(jsonInput);

    final output = await packIntoCell(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = RequestPermissionsInput.fromJson(jsonInput);

    final output = await requestPermissions(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = RunLocalInput.fromJson(jsonInput);

    final output = await runLocal(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = SendExternalMessageInput.fromJson(jsonInput);

    final output = await sendExternalMessage(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = SendMessageInput.fromJson(jsonInput);

    final output = await sendMessage(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = SplitTvcInput.fromJson(jsonInput);

    final output = await splitTvc(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = SubscribeInput.fromJson(jsonInput);

    final output = await subscribe(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = UnpackFromCellInput.fromJson(jsonInput);

    final output = await unpackFromCell(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode(output.toJson());

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

    final input = UnsubscribeInput.fromJson(jsonInput);

    await unsubscribe(
      origin: (await controller.getCurrentOrigin())!,
      input: input,
    );

    final jsonOutput = jsonEncode({});

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
