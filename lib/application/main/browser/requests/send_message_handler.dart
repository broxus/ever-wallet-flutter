import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_message_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_message_output.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> sendMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required TonWalletsRepository tonWalletsRepository,
  required KeysRepository keysRepository,
}) async {
  try {
    logger.d('sendMessage', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendMessageInput.fromJson(jsonInput);

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

    final tonWallet = await tonWalletsRepository.getTonWallet(input.sender);

    final unsignedMessage = await tonWallet.prepareTransfer(
      publicKey: publicKey,
      destination: repackedRecipient,
      amount: input.amount,
      body: body,
      bounce: kMessageBounce,
      expiration: kDefaultMessageExpiration,
    );

    await unsignedMessage.refreshTimeout();

    final hash = await unsignedMessage.hash;

    final signature = await keysRepository.sign(
      data: hash,
      publicKey: publicKey,
      password: password,
    );

    final signedMessage = await unsignedMessage.sign(signature);

    final transaction = await tonWallet.send(signedMessage);

    if (transaction == null) throw Exception('Unable to parse transaction');

    final output = SendMessageOutput(
      transaction: transaction,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('sendMessage', err, st);
    rethrow;
  }
}
