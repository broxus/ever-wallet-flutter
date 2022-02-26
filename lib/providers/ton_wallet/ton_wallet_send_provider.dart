import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletSendProvider = StateNotifierProvider.autoDispose<TonWalletSendNotifier, AsyncValue<PendingTransaction>>(
  (ref) => TonWalletSendNotifier(ref.read),
);

class TonWalletSendNotifier extends StateNotifier<AsyncValue<PendingTransaction>> {
  final Reader read;

  TonWalletSendNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> send({
    required String address,
    required UnsignedMessage message,
    required String publicKey,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final pendingTransaction = await getIt.get<TonWalletsRepository>().send(
            address: address,
            publicKey: publicKey,
            password: password,
            message: message,
          );

      await message.freePtr();

      return pendingTransaction;
    });
  }
}
