import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletPrepareConfirmTransactionProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareConfirmTransactionNotifier, AsyncValue<UnsignedMessage>>(
  (ref) => TonWalletPrepareConfirmTransactionNotifier(ref.read),
);

class TonWalletPrepareConfirmTransactionNotifier extends StateNotifier<AsyncValue<UnsignedMessage>> {
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
          .get<NekotonService>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TonWalletNotFoundException(),
          );

      return tonWallet.prepareConfirmTransaction(
        publicKey: publicKey,
        transactionId: transactionId,
        expiration: kDefaultMessageExpiration,
      );
    });
  }
}
