import 'dart:async';

import 'package:ever_wallet/application/main/browser/events/message_status_updated_handler.dart';
import 'package:ever_wallet/application/main/browser/events/models/message_status_updated_event.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/delayed_message.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_external_message_delayed_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_external_message_delayed_output.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> sendExternalMessageDelayedHandler({
  required InAppWebViewController controller,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required KeysRepository keysRepository,
  required TonWalletsRepository tonWalletsRepository,
  required GenericContractsRepository genericContractsRepository,
  required List<dynamic> args,
}) async {
  try {
    logger.d('sendExternalMessageDelayed', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendExternalMessageDelayedInput.fromJson(jsonInput);

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

    final transaction = await genericContractsRepository.send(
      address: repackedRecipient,
      signedMessage: signedMessage,
    );

    final event = MessageStatusUpdatedEvent(
      address: repackedRecipient,
      hash: signedMessage.hash,
      transaction: transaction,
    );

    messageStatusUpdatedHandler(
      controller: controller,
      event: event,
    );

    final message = DelayedMessage(
      hash: signedMessage.hash,
      account: repackedRecipient,
      expireAt: signedMessage.expireAt,
    );

    final output = SendExternalMessageDelayedOutput(
      message: message,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('sendExternalMessage', err, st);
    rethrow;
  }
}
