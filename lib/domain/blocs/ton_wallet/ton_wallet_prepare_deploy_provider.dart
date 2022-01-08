import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletPrepareDeployProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareDeployNotifier, AsyncValue<UnsignedMessage>>(
  (ref) => TonWalletPrepareDeployNotifier(ref.read),
);

class TonWalletPrepareDeployNotifier extends StateNotifier<AsyncValue<UnsignedMessage>> {
  final Reader read;

  TonWalletPrepareDeployNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareDeploy({
    required String address,
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

      return tonWallet.prepareDeploy(kDefaultMessageExpiration);
    });
  }
}
