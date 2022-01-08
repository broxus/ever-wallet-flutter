import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletPrepareTransferProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareTransferNotifier, AsyncValue<UnsignedMessage>>(
  (ref) => TonWalletPrepareTransferNotifier(ref.read),
);

class TonWalletPrepareTransferNotifier extends StateNotifier<AsyncValue<UnsignedMessage>> {
  final Reader read;

  TonWalletPrepareTransferNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareTransfer({
    required String address,
    required String publicKey,
    required String destination,
    required String amount,
    String? body,
    bool isComment = true,
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

      final repackedDestination = repackAddress(destination);

      final amountValue = int.parse(amount);

      return tonWallet.prepareTransfer(
        publicKey: publicKey,
        destination: repackedDestination,
        amount: amountValue,
        body: body,
        isComment: isComment,
        expiration: kDefaultMessageExpiration,
      );
    });
  }
}
