import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../data/exceptions.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tokenWalletPrepareTransferProvider =
    StateNotifierProvider.autoDispose<TokenWalletPrepareTransferNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TokenWalletPrepareTransferNotifier(ref.read),
);

class TokenWalletPrepareTransferNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  final Reader read;

  TokenWalletPrepareTransferNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareTransfer({
    required String publicKey,
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

      final internalMessage = await tokenWallet.prepareTransfer(
        destination: repackedDestination,
        tokens: amount,
        notifyReceiver: notifyReceiver,
        payload: payload,
      );

      final tonWallet = await getIt
          .get<NekotonService>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == owner)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TonWalletNotFoundException(),
          );

      final amountValue = int.parse(internalMessage.amount);

      final message = await tonWallet.prepareTransfer(
        publicKey: publicKey,
        destination: repackedDestination,
        amount: amountValue,
        body: internalMessage.body,
        isComment: false,
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
