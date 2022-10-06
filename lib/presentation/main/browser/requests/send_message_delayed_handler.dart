import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/ton_wallets_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../events/message_status_updated_handler.dart';
import '../events/models/message_status_updated_event.dart';
import '../extensions.dart';
import 'models/delayed_message.dart';
import 'models/send_message_delayed_input.dart';
import 'models/send_message_delayed_output.dart';

Future<Map<String, dynamic>> sendMessageDelayedHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('sendMessageDelayed', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendMessageDelayedInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

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

    final tuple = await getIt.get<ApprovalsRepository>().sendMessage(
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

    final unsignedMessage = await getIt.get<TonWalletsRepository>().prepareTransfer(
          address: input.sender,
          publicKey: publicKey,
          destination: repackedRecipient,
          amount: input.amount,
          body: body,
        );

    try {
      await unsignedMessage.refreshTimeout();

      final hash = await unsignedMessage.hash;

      final signature = await getIt.get<KeysRepository>().sign(
            data: hash,
            publicKey: publicKey,
            password: password,
          );

      final signedMessage = await unsignedMessage.sign(signature);

      final pendingTransaction = await getIt.get<TonWalletsRepository>().send(
            address: input.sender,
            signedMessage: signedMessage,
          );

      () async {
        final transaction = await getIt
            .get<TonWalletsRepository>()
            .getSentMessagesStream(input.sender)
            .whereType<List<Tuple2<PendingTransaction, Transaction?>>>()
            .expand((e) => e)
            .firstWhere((e) => e.item1 == pendingTransaction)
            .then((v) => v.item2!)
            .timeout(Duration(seconds: signedMessage.expireAt));

        final event = MessageStatusUpdatedEvent(
          address: repackedRecipient,
          hash: signedMessage.hash,
          transaction: transaction,
        );

        messageStatusUpdatedHandler(
          controller: controller,
          event: event,
        );
      }();

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
    } finally {
      unsignedMessage.freePtr();
    }
  } catch (err, st) {
    logger.e('sendMessageDelayed', err, st);
    rethrow;
  }
}
