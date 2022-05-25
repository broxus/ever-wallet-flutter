import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/constants.dart';
import '../../../../data/repositories/transport_repository.dart';
import '../extensions.dart';
import 'models/send_unsigned_external_message_input.dart';
import 'models/send_unsigned_external_message_output.dart';

Future<Map<String, dynamic>> sendUnsignedExternalMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('sendUnsignedExternalMessage', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendUnsignedExternalMessageInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    final repackedRecipient = repackAddress(input.recipient);

    final signedMessage = createExternalMessageWithoutSignature(
      dst: repackedRecipient,
      contractAbi: input.payload.abi,
      method: input.payload.method,
      stateInit: input.stateInit,
      input: input.payload.params,
      timeout: kDefaultMessageTimeout,
    );

    Transaction transaction;

    final transport = await getIt.get<TransportRepository>().transport;
    final genericContract = await GenericContract.subscribe(
      transport: transport,
      address: repackedRecipient,
    );

    try {
      if (input.local == true) {
        transaction = await genericContract.executeTransactionLocally(
          signedMessage: signedMessage,
          options: const TransactionExecutionOptions(disableSignatureCheck: false),
        );
      } else {
        final pendingTransaction = await genericContract.send(signedMessage);

        transaction = await genericContract.onMessageSentStream
            .firstWhere((e) => e.pendingTransaction == pendingTransaction)
            .then((v) => v.transaction!);
      }

      TokensObject? decodedOutput;

      try {
        decodedOutput = decodeTransaction(
          transaction: transaction,
          contractAbi: input.payload.abi,
          method: input.payload.method,
        )?.output;
      } catch (_) {}

      final output = SendUnsignedExternalMessageOutput(
        transaction: transaction,
        output: decodedOutput,
      );

      final jsonOutput = output.toJson();

      return jsonOutput;
    } finally {
      genericContract.freePtr();
    }
  } catch (err, st) {
    logger.e('sendUnsignedExternalMessage', err, st);
    rethrow;
  }
}
