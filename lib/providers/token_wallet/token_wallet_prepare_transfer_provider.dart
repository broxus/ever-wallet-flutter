import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/token_wallets_repository.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tokenWalletPrepareTransferProvider =
    StateNotifierProvider.autoDispose<TokenWalletPrepareTransferNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TokenWalletPrepareTransferNotifier(),
);

class TokenWalletPrepareTransferNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  UnsignedMessage? _message;

  TokenWalletPrepareTransferNotifier() : super(const AsyncValue.loading());

  @override
  void dispose() {
    _message?.freePtr();
    super.dispose();
  }

  Future<void> prepareTransfer({
    required String publicKey,
    required String owner,
    required String rootTokenContract,
    required String destination,
    required String amount,
    required bool notifyReceiver,
    String? payload,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repackedDestination = repackAddress(destination);

      final internalMessage = await getIt.get<TokenWalletsRepository>().prepareTransfer(
            owner: owner,
            rootTokenContract: rootTokenContract,
            destination: repackedDestination,
            tokens: amount,
            notifyReceiver: notifyReceiver,
            payload: payload,
          );

      final amountValue = int.parse(internalMessage.amount);

      final message = await getIt.get<TonWalletsRepository>().prepareTransfer(
            address: owner,
            publicKey: publicKey,
            destination: internalMessage.destination,
            amount: internalMessage.amount,
            body: internalMessage.body,
          );

      _message?.freePtr();
      _message = message;

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: owner,
            message: message,
          );
      final feesValue = int.parse(fees);

      final balance =
          await getIt.get<TonWalletsRepository>().getInfoStream(owner).first.then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

      if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

      return Tuple2(message, fees);
    });
  }
}
