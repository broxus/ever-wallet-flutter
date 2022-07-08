import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_unsigned_external_message_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_unsigned_external_message_output.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> sendUnsignedExternalMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
}) async {
  try {
    logger.d('sendUnsignedExternalMessage', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SendUnsignedExternalMessageInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

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

    final transport = await transportRepository.transport;
    final genericContract = await GenericContract.subscribe(
      transport: transport,
      address: repackedRecipient,
      preloadTransactions: false,
    );

    try {
      if (input.local == true) {
        transaction = await genericContract.executeTransactionLocally(
          signedMessage: signedMessage,
          options: const TransactionExecutionOptions(disableSignatureCheck: false),
        );
      } else {
        final sent = await genericContract.send(signedMessage);

        if (sent == null) throw Exception('Unable to parse transaction');

        transaction = sent;
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
      genericContract.dispose();
    }
  } catch (err, st) {
    logger.e('sendUnsignedExternalMessage', err, st);
    rethrow;
  }
}
