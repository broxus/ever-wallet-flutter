import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../injection.dart';
import '../../data/repositories/keys_repository.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletSendProvider = StateNotifierProvider.autoDispose<TonWalletSendNotifier, AsyncValue<PendingTransaction>>(
  (ref) => TonWalletSendNotifier(),
);

class TonWalletSendNotifier extends StateNotifier<AsyncValue<PendingTransaction>> {
  TonWalletSendNotifier() : super(const AsyncValue.loading());

  Future<void> send({
    required String address,
    required UnsignedMessage unsignedMessage,
    required String publicKey,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        await unsignedMessage.refreshTimeout();

        final hash = await unsignedMessage.hash;

        final signature = await getIt.get<KeysRepository>().sign(
              data: hash,
              publicKey: publicKey,
              password: password,
            );

        final signedMessage = await unsignedMessage.sign(signature);

        final pendingTransaction = await getIt.get<TonWalletsRepository>().send(
              address: address,
              signedMessage: signedMessage,
            );

        return pendingTransaction;
      } finally {
        unsignedMessage.freePtr();
      }
    });
  }
}
