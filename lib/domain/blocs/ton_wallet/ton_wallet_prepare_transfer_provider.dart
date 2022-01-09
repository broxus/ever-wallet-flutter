import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../data/exceptions.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletPrepareTransferProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareTransferNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareTransferNotifier(ref.read),
);

class TonWalletPrepareTransferNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
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

      final message = await tonWallet.prepareTransfer(
        publicKey: publicKey,
        destination: repackedDestination,
        amount: amountValue,
        body: body,
        isComment: isComment,
        expiration: kDefaultMessageExpiration,
      );

      final feesValue = await tonWallet.estimateFees(message);
      final fees = feesValue.toString();

      final balance = await tonWallet.contractState.then((value) => value.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

      if (isPossibleToSendMessage) {
        return Tuple2(message, fees);
      } else {
        throw InsufficientFundsException();
      }
    });
  }
}
