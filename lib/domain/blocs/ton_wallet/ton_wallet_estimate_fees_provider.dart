import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/exceptions.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletEstimateFeesProvider =
    StateNotifierProvider.autoDispose<TonWalletEstimateFeesNotifier, AsyncValue<String>>(
  (ref) => TonWalletEstimateFeesNotifier(ref.read),
);

class TonWalletEstimateFeesNotifier extends StateNotifier<AsyncValue<String>> {
  final Reader read;

  TonWalletEstimateFeesNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> estimateFees({
    required String address,
    required UnsignedMessage message,
    String amount = '0',
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final tonWallet = await getIt
          .get<NekotonService>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TonWalletNotFoundException(),
          );

      final feesValue = await tonWallet.estimateFees(message);
      final fees = feesValue.toString();

      final balance = await tonWallet.contractState.then((value) => value.balance);
      final balanceValue = int.parse(balance);

      final amountValue = int.parse(amount);

      final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

      if (isPossibleToSendMessage) {
        return fees;
      } else {
        throw InsufficientFundsException();
      }
    });
  }
}
