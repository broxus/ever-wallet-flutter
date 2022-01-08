import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletPrepareDeployWithMultipleOwnersProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareDeployWithMultipleOwnersNotifier, AsyncValue<UnsignedMessage>>(
  (ref) => TonWalletPrepareDeployWithMultipleOwnersNotifier(ref.read),
);

class TonWalletPrepareDeployWithMultipleOwnersNotifier extends StateNotifier<AsyncValue<UnsignedMessage>> {
  final Reader read;

  TonWalletPrepareDeployWithMultipleOwnersNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareDeployWithMultipleOwners({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
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

      return tonWallet.prepareDeployWithMultipleOwners(
        expiration: kDefaultMessageExpiration,
        custodians: custodians,
        reqConfirms: reqConfirms,
      );
    });
  }
}
