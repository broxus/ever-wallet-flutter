import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../data/constants.dart';
import '../../../data/repositories/ton_wallets_subscriptions_repository.dart';
import '../../../injection.dart';

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
      final tonWallet = await getIt
          .get<TonWalletsSubscriptionsRepository>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception(),
          );

      final message = await tonWallet.prepareConfirmTransaction(
        publicKey: publicKey,
        transactionId: transactionId,
        expiration: kDefaultMessageExpiration,
      );

      final fees = await tonWallet.estimateFees(message);
      final feesValue = int.parse(fees);

      final balance = await tonWallet.contractState.then((v) => v.balance);
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
