import 'dart:async';
import 'dart:convert';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/estimate_fees_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/estimate_fees_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> estimateFeesHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TonWalletsRepository tonWalletsRepository,
}) async {
  try {
    logger.d('estimateFees', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = EstimateFeesInput.fromJson(jsonInput);

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

    if (input.payload != null) {
      body = encodeInternalInput(
        contractAbi: input.payload!.abi,
        method: input.payload!.method,
        input: input.payload!.params,
      );
    }

    final unsignedMessage = await tonWalletsRepository.prepareTransfer(
      address: input.sender,
      destination: repackedRecipient,
      amount: input.amount,
      body: body,
    );

    final signature = base64.encode(List.generate(kSignatureLength, (_) => 0));

    await unsignedMessage.refreshTimeout();

    final signedMessage = await unsignedMessage.sign(signature);

    final fees = await tonWalletsRepository.estimateFees(
      address: input.sender,
      signedMessage: signedMessage,
    );

    final output = EstimateFeesOutput(
      fees: fees,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('estimateFees', err, st);
    rethrow;
  }
}
