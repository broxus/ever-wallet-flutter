import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/repositories/keystore_repository.dart';
import '../../../data/repositories/ton_wallets_subscriptions_repository.dart';
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
          .get<TonWalletsSubscriptionsRepository>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception(),
          );

      final key = getIt.get<KeystoreRepository>().keys.firstWhere((e) => e.publicKey == publicKey);

      final signInput = key.isLegacy
          ? EncryptedKeyPassword(
              publicKey: key.publicKey,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            )
          : DerivedKeySignParams.byAccountId(
              masterKey: key.masterKey,
              accountId: key.accountId,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );

      final pendingTransaction = await tonWallet.send(
        keystore: getIt.get<KeystoreRepository>().keystore,
        message: message,
        signInput: signInput,
      );

      await message.freePtr();

      return pendingTransaction;
    });
  }
}
