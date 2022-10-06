import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/ton_wallets_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/constants.dart';
import '../../../../data/repositories/approvals_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../events/message_status_updated_handler.dart';
import '../events/models/message_status_updated_event.dart';
import '../extensions.dart';
import 'models/delayed_message.dart';
import 'models/send_external_message_delayed_input.dart';
import 'models/send_external_message_delayed_output.dart';

Future<Map<String, dynamic>> sendExternalMessageDelayedHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('sendExternalMessageDelayed', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendExternalMessageDelayedInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.publicKey != input.publicKey) {
      throw Exception('Specified signer is not allowed');
    }

    final repackedRecipient = repackAddress(input.recipient);

    final unsignedMessage = createExternalMessage(
      dst: repackedRecipient,
      contractAbi: input.payload.abi,
      method: input.payload.method,
      stateInit: input.stateInit,
      input: input.payload.params,
      publicKey: input.publicKey,
      timeout: kDefaultMessageTimeout,
    );

    try {
      final password = await getIt.get<ApprovalsRepository>().callContractMethod(
            origin: origin,
            publicKey: input.publicKey,
            recipient: repackedRecipient,
            payload: input.payload,
          );

      await unsignedMessage.refreshTimeout();

      final hash = await unsignedMessage.hash;

      final signature = await getIt.get<KeysRepository>().sign(
            data: hash,
            publicKey: input.publicKey,
            password: password,
          );

      final signedMessage = await unsignedMessage.sign(signature);

      Transaction transaction;

      final pendingTransaction = await getIt.get<TonWalletsRepository>().send(
            address: repackedRecipient,
            signedMessage: signedMessage,
          );

      () async {
        transaction = await getIt
            .get<TonWalletsRepository>()
            .getSentMessagesStream(repackedRecipient)
            .map((event) => null)
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

      final output = SendExternalMessageDelayedOutput(
        message: message,
      );

      final jsonOutput = output.toJson();

      return jsonOutput;
    } finally {
      unsignedMessage.freePtr();
    }
  } catch (err, st) {
    logger.e('sendExternalMessage', err, st);
    rethrow;
  }
}
