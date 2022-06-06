import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletPrepareConfirmTransactionProvider = StateNotifierProvider.autoDispose<
    TonWalletPrepareConfirmTransactionNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareConfirmTransactionNotifier(),
);

class TonWalletPrepareConfirmTransactionNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  UnsignedMessage? _unsignedMessage;

  TonWalletPrepareConfirmTransactionNotifier() : super(const AsyncValue.loading());

  @override
  void dispose() {
    _unsignedMessage?.freePtr();
    super.dispose();
  }

  Future<void> prepareConfirmTransaction({
    required String publicKey,
    required String address,
    required String transactionId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _unsignedMessage?.freePtr();

      final unsignedMessage = await getIt.get<TonWalletsRepository>().prepareConfirmTransaction(
            address: address,
            publicKey: publicKey,
            transactionId: transactionId,
          );

      _unsignedMessage = unsignedMessage;

      await unsignedMessage.refreshTimeout();

      final signature = base64.encode(List.generate(kSignatureLength, (_) => 0));

      final signedMessage = await unsignedMessage.sign(signature);

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            signedMessage: signedMessage,
          );
      final feesValue = int.parse(fees);

      final balance = await getIt.get<TonWalletsRepository>().getInfo(address).then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > feesValue;

      if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

      return Tuple2(unsignedMessage, fees);
    });
  }
}
