import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletPrepareConfirmTransactionProvider = StateNotifierProvider.autoDispose<
    TonWalletPrepareConfirmTransactionNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareConfirmTransactionNotifier(ref.read),
);

class TonWalletPrepareConfirmTransactionNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  final Reader read;

  TonWalletPrepareConfirmTransactionNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareConfirmTransaction({
    required String publicKey,
    required String address,
    required String transactionId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final message = await getIt.get<TonWalletsRepository>().prepareConfirmTransaction(
            address: address,
            publicKey: publicKey,
            transactionId: transactionId,
          );

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            message: message,
          );
      final feesValue = int.parse(fees);

      final balance =
          await getIt.get<TonWalletsRepository>().getInfoStream(address).first.then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > feesValue;

      if (isPossibleToSendMessage) {
        return Tuple2(message, fees);
      } else {
        throw Exception();
      }
    });
  }
}
