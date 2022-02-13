import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/provider_repository.dart';
import '../../../../../injection.dart';
import 'controller_extensions.dart';

Future<dynamic> codeToTvcHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;

    final input = CodeToTvcInput.fromJson(jsonInput);

    final output = await getIt.get<ProviderRepository>().codeToTvc(
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

    final output = await getIt.get<ProviderRepository>().decodeEvent(
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

    final output = await getIt.get<ProviderRepository>().decodeInput(
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

    final output = await getIt.get<ProviderRepository>().decodeOutput(
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

    final output = await getIt.get<ProviderRepository>().decodeTransactionEvents(
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

    final output = await getIt.get<ProviderRepository>().decodeTransaction(
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
    await getIt.get<ProviderRepository>().disconnect(
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

    final output = await getIt.get<ProviderRepository>().encodeInternalInput(
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

    final output = await getIt.get<ProviderRepository>().estimateFees(
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

    final output = await getIt.get<ProviderRepository>().extractPublicKey(
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

    final output = await getIt.get<ProviderRepository>().getExpectedAddress(
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

    final output = await getIt.get<ProviderRepository>().getFullContractState(
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
    final output = await getIt.get<ProviderRepository>().getProviderState(
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

    final output = await getIt.get<ProviderRepository>().getTransactions(
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

    final output = await getIt.get<ProviderRepository>().packIntoCell(
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

    final output = await getIt.get<ProviderRepository>().requestPermissions(
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

    final output = await getIt.get<ProviderRepository>().runLocal(
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

    final output = await getIt.get<ProviderRepository>().sendExternalMessage(
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

    final output = await getIt.get<ProviderRepository>().sendMessage(
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

    final output = await getIt.get<ProviderRepository>().splitTvc(
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

    final output = await getIt.get<ProviderRepository>().subscribe(
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

    final output = await getIt.get<ProviderRepository>().unpackFromCell(
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
    await getIt.get<ProviderRepository>().unsubscribeAll(
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

    await getIt.get<ProviderRepository>().unsubscribe(
          origin: (await controller.getCurrentOrigin())!,
          input: input,
        );

    final jsonOutput = jsonEncode({});

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
