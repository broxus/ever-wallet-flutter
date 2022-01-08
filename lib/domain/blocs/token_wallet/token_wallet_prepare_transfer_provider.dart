import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tokenWalletPrepareTransferProvider =
    StateNotifierProvider.autoDispose<TokenWalletPrepareTransferNotifier, AsyncValue<InternalMessage>>(
  (ref) => TokenWalletPrepareTransferNotifier(ref.read),
);

class TokenWalletPrepareTransferNotifier extends StateNotifier<AsyncValue<InternalMessage>> {
  final Reader read;

  TokenWalletPrepareTransferNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareTransfer({
    required String owner,
    required String rootTokenContract,
    required String destination,
    required String amount,
    required bool notifyReceiver,
    String? payload,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final tokenWallet = await getIt
          .get<NekotonService>()
          .tokenWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.owner == owner && e.symbol.rootTokenContract == rootTokenContract)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TokenWalletNotFoundException(),
          );

      final repackedDestination = repackAddress(destination);

      return tokenWallet.prepareTransfer(
        destination: repackedDestination,
        tokens: amount,
        notifyReceiver: notifyReceiver,
        payload: payload,
      );
    });
  }
}
