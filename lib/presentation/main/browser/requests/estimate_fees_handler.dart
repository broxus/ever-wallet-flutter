import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/ton_wallets_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/estimate_fees_input.dart';
import 'models/estimate_fees_output.dart';

Future<Map<String, dynamic>> estimateFeesHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('estimateFees', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = EstimateFeesInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    if (existingPermissions?.accountInteraction?.address != input.sender) {
      throw Exception('Specified sender is not allowed');
    }

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
          address: input.sender,
          destination: repackedRecipient,
          amount: input.amount,
          body: body,
        );

    try {
      final signature = base64.encode(List.generate(kSignatureLength, (_) => 0));

      await unsignedMessage.refreshTimeout();

      final signedMessage = await unsignedMessage.sign(signature);

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: input.sender,
            signedMessage: signedMessage,
          );

      final output = EstimateFeesOutput(
        fees: fees,
      );

      final jsonOutput = output.toJson();

      return jsonOutput;
    } finally {
      unsignedMessage.freePtr();
    }
  } catch (err, st) {
    logger.e('estimateFees', err, st);
    rethrow;
  }
}
