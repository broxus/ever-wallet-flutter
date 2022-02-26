import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/constants.dart';
import '../../../../../data/extensions.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/ton_wallets_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import 'controller_extensions.dart';

Future<dynamic> codeToTvcHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;

    final input = CodeToTvcInput.fromJson(jsonInput);

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final tvc = codeToTvc(input.code);

    final output = CodeToTvcOutput(
      tvc: tvc,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = decodeEvent(
      messageBody: input.body,
      contractAbi: input.abi,
      event: input.event,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = decodeInput(
      messageBody: input.body,
      contractAbi: input.abi,
      method: input.method,
      internal: input.internal,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = decodeOutput(
      messageBody: input.body,
      contractAbi: input.abi,
      method: input.method,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final events = decodeTransactionEvents(
      transaction: input.transaction,
      contractAbi: input.abi,
    );

    final output = DecodeTransactionEventsOutput(
      events: events,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = decodeTransaction(
      transaction: input.transaction,
      contractAbi: input.abi,
      method: input.method,
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
    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().deletePermissions(currentOrigin);

    await getIt.get<GenericContractsRepository>().clear();

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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final boc = encodeInternalInput(
      contractAbi: input.abi,
      method: input.method,
      input: input.params,
    );

    final output = EncodeInternalInputOutput(
      boc: boc,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.address != input.sender) throw Exception();

    final selectedAddress = allowedAccount!.address;
    final repackedRecipient = repackAddress(input.recipient);

    String? body;
    if (input.payload != null) {
      body = encodeInternalInput(
        contractAbi: input.payload!.abi,
        method: input.payload!.method,
        input: input.payload!.params,
      );
    }

    final unsignedMessage = await getIt.get<TonWalletsRepository>().prepareTransfer(
          address: selectedAddress,
          destination: repackedRecipient,
          amount: input.amount,
          body: body,
        );

    final fees = await getIt.get<TonWalletsRepository>().estimateFees(
          address: selectedAddress,
          message: unsignedMessage,
        );

    final output = EstimateFeesOutput(
      fees: fees,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final publicKey = extractPublicKey(input.boc);

    final output = ExtractPublicKeyOutput(
      publicKey: publicKey,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final address = getExpectedAddress(
      tvc: input.tvc,
      contractAbi: input.abi,
      workchainId: input.workchain,
      publicKey: input.publicKey,
      initData: input.initParams,
    );

    final output = GetExpectedAddressOutput(
      address: address,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = getIt.get<TransportRepository>().transport;

    if (transport == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final state = await transport.getFullAccountState(address: input.address);

    final output = GetFullContractStateOutput(
      state: state,
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
    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = getIt.get<TransportRepository>().transport;

    if (transport == null) throw Exception();

    const version = kProviderVersion;
    final numericVersion = kProviderVersion.toInt();
    final selectedConnection = transport.connectionData.name;
    const supportedPermissions = Permission.values;
    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final subscriptions = await getIt.get<GenericContractsRepository>().subscriptions;

    final output = GetProviderStateOutput(
      version: version,
      numericVersion: numericVersion,
      selectedConnection: selectedConnection,
      supportedPermissions: supportedPermissions,
      permissions: permissions,
      subscriptions: subscriptions,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = getIt.get<TransportRepository>().transport;

    if (transport == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = await transport.getTransactions(
      address: input.address,
      continuation: input.continuation,
      limit: input.limit,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final boc = packIntoCell(
      params: input.structure,
      tokens: input.data,
    );

    final output = PackIntoCellOutput(
      boc: boc,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    late Permissions requested;

    try {
      requested = await getIt.get<PermissionsRepository>().checkPermissions(
            origin: currentOrigin,
            requiredPermissions: input.permissions,
          );
    } catch (_) {
      requested = await getIt.get<ApprovalsRepository>().requestApprovalForPermissions(
            origin: currentOrigin,
            permissions: input.permissions,
          );

      await getIt.get<PermissionsRepository>().setPermissions(
            origin: currentOrigin,
            permissions: requested,
          );
    }

    final output = requested;

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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = getIt.get<TransportRepository>().transport;

    if (transport == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    FullContractState? contractState = input.cachedState;

    if (input.cachedState == null) {
      contractState = await transport.getFullAccountState(address: input.address);
    }

    if (contractState == null) throw Exception();

    if (!contractState.isDeployed) throw Exception();

    final output = runLocal(
      accountStuffBoc: contractState.boc,
      contractAbi: input.functionCall.abi,
      method: input.functionCall.method,
      input: input.functionCall.params,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = getIt.get<TransportRepository>().transport;

    if (transport == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.publicKey != input.publicKey) {
      throw Exception();
    }

    final selectedPublicKey = allowedAccount!.publicKey;
    final selectedAddress = allowedAccount.address;
    final repackedRecipient = repackAddress(input.recipient);

    final message = createExternalMessage(
      dst: repackedRecipient,
      contractAbi: input.payload.abi,
      method: input.payload.method,
      stateInit: input.stateInit,
      input: input.payload.params,
      publicKey: selectedPublicKey,
      timeout: 30,
    );

    final password = await getIt.get<ApprovalsRepository>().requestApprovalToCallContractMethod(
          origin: currentOrigin,
          selectedPublicKey: selectedPublicKey,
          repackedRecipient: repackedRecipient,
          payload: input.payload,
        );

    Transaction transaction;
    if (input.local == true) {
      transaction = await getIt.get<GenericContractsRepository>().executeTransactionLocally(
            address: selectedAddress,
            publicKey: selectedPublicKey,
            password: password,
            message: message,
            options: const TransactionExecutionOptions(disableSignatureCheck: false),
          );
    } else {
      final pendingTransaction = await getIt.get<GenericContractsRepository>().send(
            address: selectedAddress,
            publicKey: selectedPublicKey,
            password: password,
            message: message,
          );

      await message.freePtr();

      transaction = await getIt
          .get<TonWalletsRepository>()
          .getSentMessagesStream(selectedAddress)
          .expand((e) => e)
          .firstWhere((e) => e.item1 == pendingTransaction)
          .then((v) => v.item2!);
    }

    TokensObject? decodedOutput;
    try {
      final decoded = decodeTransaction(
        transaction: transaction,
        contractAbi: input.payload.abi,
        method: input.payload.method,
      );
      decodedOutput = decoded?.output;
    } catch (_) {}

    final output = SendExternalMessageOutput(
      transaction: transaction,
      output: decodedOutput,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.address != input.sender) throw Exception();

    final selectedAddress = allowedAccount!.address;
    final repackedRecipient = repackAddress(input.recipient);

    String? body;
    KnownPayload? knownPayload;
    if (input.payload != null) {
      body = encodeInternalInput(
        contractAbi: input.payload!.abi,
        method: input.payload!.method,
        input: input.payload!.params,
      );
      knownPayload = parseKnownPayload(body);
    }

    final tuple = await getIt.get<ApprovalsRepository>().requestApprovalToSendMessage(
          origin: currentOrigin,
          sender: selectedAddress,
          recipient: repackedRecipient,
          amount: input.amount,
          bounce: input.bounce,
          payload: input.payload,
          knownPayload: knownPayload,
        );

    final publicKey = tuple.item1;
    final password = tuple.item2;

    final message = await getIt.get<TonWalletsRepository>().prepareTransfer(
          address: selectedAddress,
          publicKey: publicKey,
          destination: repackedRecipient,
          amount: input.amount,
          body: body,
        );

    final pendingTransaction = await getIt.get<TonWalletsRepository>().send(
          address: selectedAddress,
          publicKey: publicKey,
          password: password,
          message: message,
        );

    await message.freePtr();

    final transaction = await getIt
        .get<TonWalletsRepository>()
        .getSentMessagesStream(selectedAddress)
        .expand((e) => e)
        .firstWhere((e) => e.item1 == pendingTransaction)
        .then((v) => v.item2!);

    final output = SendMessageOutput(
      transaction: transaction,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = splitTvc(input.tvc);

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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    if (!validateAddress(input.address)) throw Exception();

    await getIt.get<GenericContractsRepository>().subscribe(input.address);

    const output = ContractUpdatesSubscription(
      state: true,
      transactions: true,
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

    final currentOrigin = await controller.getCurrentOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final data = unpackFromCell(
      params: input.structure,
      boc: input.boc,
      allowPartial: input.allowPartial,
    );

    final output = UnpackFromCellOutput(
      data: data,
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
    await getIt.get<GenericContractsRepository>().clear();

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

    if (!validateAddress(input.address)) throw Exception();

    await getIt.get<GenericContractsRepository>().unsubscribe(input.address);

    final jsonOutput = jsonEncode({});

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
