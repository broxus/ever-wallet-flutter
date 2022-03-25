import 'dart:async';
import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/approvals_repository.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/ton_wallets_repository.dart';
import '../../../../../injection.dart';
import '../custom_in_app_web_view_controller.dart';

Future<dynamic> sendExternalMessageHandler({
  required CustomInAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;

    final input = SendExternalMessageInput.fromJson(jsonInput);

    final currentOrigin = await controller.controller.getUrl().then((v) => v?.authority);

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.publicKey != input.publicKey) {
      throw Exception();
    }

    final selectedPublicKey = allowedAccount!.publicKey;
    final selectedAddress = allowedAccount.address;
    final repackedRecipient = repackAddress(input.recipient);

    final message = createExternalMessage(
      dst: repackedRecipient,
      contractAbi: input.payload.abi,
      method: input.payload.method,
      stateInit: input.stateInit,
      input: input.payload.params,
      publicKey: selectedPublicKey,
      timeout: 30,
    );

    final password = await getIt.get<ApprovalsRepository>().requestToCallContractMethod(
          origin: currentOrigin,
          publicKey: selectedPublicKey,
          recipient: repackedRecipient,
          payload: input.payload,
        );

    Transaction transaction;
    if (input.local == true) {
      transaction = await getIt.get<GenericContractsRepository>().executeTransactionLocally(
            address: selectedAddress,
            publicKey: selectedPublicKey,
            password: password,
            message: message,
            options: const TransactionExecutionOptions(disableSignatureCheck: false),
          );
    } else {
      final pendingTransaction = await getIt.get<GenericContractsRepository>().send(
            address: selectedAddress,
            publicKey: selectedPublicKey,
            password: password,
            message: message,
          );

      message.freePtr();

      transaction = await getIt
          .get<TonWalletsRepository>()
          .getSentMessagesStream(selectedAddress)
          .map((event) => null)
          .whereType<List<Tuple2<PendingTransaction, Transaction?>>>()
          .expand((e) => e)
          .firstWhere((e) => e.item1 == pendingTransaction)
          .then((v) => v.item2!);
    }

    TokensObject? decodedOutput;
    try {
      final decoded = decodeTransaction(
        transaction: transaction,
        contractAbi: input.payload.abi,
        method: input.payload.method,
      );
      decodedOutput = decoded?.output;
    } catch (_) {}

    final output = SendExternalMessageOutput(
      transaction: transaction,
      output: decodedOutput,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
