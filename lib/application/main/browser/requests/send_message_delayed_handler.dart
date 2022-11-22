import 'dart:async';

import 'package:ever_wallet/application/main/browser/events/message_status_updated_handler.dart';
import 'package:ever_wallet/application/main/browser/events/models/message_status_updated_event.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/delayed_message.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_message_delayed_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_message_delayed_output.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/signed_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> sendMessageDelayedHandler({
  required InAppWebViewController controller,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required TonWalletsRepository tonWalletsRepository,
  required KeysRepository keysRepository,
  required List<dynamic> args,
}) async {
  try {
    logger.d('sendMessageDelayed', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendMessageDelayedInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.address != input.sender) {
      throw Exception('Specified sender is not allowed');
    }

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

    final tuple = await approvalsRepository.sendMessage(
      origin: origin,
      sender: input.sender,
      recipient: repackedRecipient,
      amount: input.amount,
      bounce: input.bounce,
      payload: input.payload,
      knownPayload: knownPayload,
    );

    final publicKey = tuple.item1;
    final password = tuple.item2;

    final unsignedMessage = await tonWalletsRepository.prepareTransfer(
      address: input.sender,
      publicKey: publicKey,
      destination: repackedRecipient,
      amount: input.amount,
      body: body,
      bounce: kMessageBounce,
    );

    await unsignedMessage.message.refreshTimeout();

    final hash = unsignedMessage.message.hash;

    final signature = await keysRepository.sign(
      data: hash,
      publicKey: publicKey,
      password: password,
    );

    final signedMessage = await unsignedMessage.message.sign(signature);

    final transaction = await tonWalletsRepository.send(
      address: input.sender,
      signedMessageWithAdditionalInfo: SignedMessageWithAdditionalInfo(
        message: signedMessage,
        amount: unsignedMessage.amount,
        dst: unsignedMessage.dst,
      ),
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

    final output = SendMessageDelayedOutput(
      message: message,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('sendMessageDelayed', err, st);
    rethrow;
  }
}
