import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

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
      final tonWallet = await getIt
          .get<NekotonService>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TonWalletNotFoundException(),
          );

      final signInput = await getIt.get<NekotonService>().getSignInput(
            publicKey: publicKey,
            password: password,
          );

      return tonWallet.send(
        message: message,
        signInput: signInput,
      );
    });
  }
}
