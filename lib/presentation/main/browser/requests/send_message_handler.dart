import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/ton_wallets_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';

Future<dynamic> sendMessageHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('SendMessageRequest', args);

    final jsonInput = args.first as Map<String, dynamic>;

    final input = SendMessageInput.fromJson(jsonInput);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.address != input.sender) throw Exception();

    final selectedAddress = allowedAccount!.address;
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

    final tuple = await getIt.get<ApprovalsRepository>().requestToSendMessage(
          origin: currentOrigin,
          sender: selectedAddress,
          recipient: repackedRecipient,
          amount: input.amount,
          bounce: input.bounce,
          payload: input.payload,
          knownPayload: knownPayload,
        );

    final publicKey = tuple.item1;
    final password = tuple.item2;

    final message = await getIt.get<TonWalletsRepository>().prepareTransfer(
          address: selectedAddress,
          publicKey: publicKey,
          destination: repackedRecipient,
          amount: input.amount,
          body: body,
        );

    final pendingTransaction = await getIt.get<TonWalletsRepository>().send(
          address: selectedAddress,
          publicKey: publicKey,
          password: password,
          message: message,
        );

    message.freePtr();

    final transaction = await getIt
        .get<TonWalletsRepository>()
        .getSentMessagesStream(selectedAddress)
        .whereType<List<Tuple2<PendingTransaction, Transaction?>>>()
        .expand((e) => e)
        .firstWhere((e) => e.item1 == pendingTransaction)
        .then((v) => v.item2!);

    final output = SendMessageOutput(
      transaction: transaction,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
