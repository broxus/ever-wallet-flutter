import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_external_message_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_external_message_output.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> sendExternalMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required KeysRepository keysRepository,
  required GenericContractsRepository genericContractsRepository,
  required TonWalletsRepository tonWalletsRepository,
}) async {
  try {
    logger.d('sendExternalMessage', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendExternalMessageInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.publicKey != input.publicKey) {
      throw Exception('Specified signer is not allowed');
    }

    final repackedRecipient = repackAddress(input.recipient);

    final unsignedMessage = await createExternalMessage(
      dst: repackedRecipient,
      contractAbi: input.payload.abi,
      method: input.payload.method,
      stateInit: input.stateInit,
      input: input.payload.params,
      publicKey: input.publicKey,
      timeout: kDefaultMessageTimeout,
    );

    final password = await approvalsRepository.callContractMethod(
      origin: origin,
      publicKey: input.publicKey,
      recipient: repackedRecipient,
      payload: input.payload,
    );

    await unsignedMessage.refreshTimeout();

    final hash = unsignedMessage.hash;
    final transport =
        genericContractsRepository.genericContractByAddress(repackedRecipient).transport;

    final signature = await keysRepository.sign(
      data: hash,
      publicKey: input.publicKey,
      password: password,
      signatureId: await transport.getSignatureId(),
    );

    final signedMessage = await unsignedMessage.sign(signature);

    Transaction transaction;

    if (input.local == true) {
      transaction = await genericContractsRepository.executeTransactionLocally(
        address: repackedRecipient,
        signedMessage: signedMessage,
        options: const TransactionExecutionOptions(disableSignatureCheck: false),
      );
    } else {
      transaction = await genericContractsRepository.send(
        address: repackedRecipient,
        signedMessage: signedMessage,
      );
    }

    TokensObject? decodedOutput;

    try {
      decodedOutput = decodeTransaction(
        transaction: transaction,
        contractAbi: input.payload.abi,
        method: input.payload.method,
      )?.output;
    } catch (_) {}

    final output = SendExternalMessageOutput(
      transaction: transaction,
      output: decodedOutput,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('sendExternalMessage', err, st);
    rethrow;
  }
}
