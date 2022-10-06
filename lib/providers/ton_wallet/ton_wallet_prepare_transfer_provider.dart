import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletPrepareTransferProvider = StateNotifierProvider.autoDispose<
    TonWalletPrepareTransferNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareTransferNotifier(),
);

class TonWalletPrepareTransferNotifier
    extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  TonWalletPrepareTransferNotifier() : super(const AsyncValue.loading());

  Future<void> prepareTransfer({
    required String address,
    String? publicKey,
    required String destination,
    required String amount,
    String? body,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repackedDestination = repackAddress(destination);

      final amountValue = int.parse(amount);

      final unsignedMessage = await getIt.get<TonWalletsRepository>().prepareTransfer(
            address: address,
            publicKey: publicKey,
            destination: repackedDestination,
            amount: amount,
            body: body,
          );

      await unsignedMessage.refreshTimeout();

      final signature = base64.encode(List.generate(kSignatureLength, (_) => 0));

      final signedMessage = await unsignedMessage.sign(signature);

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            signedMessage: signedMessage,
          );
      final feesValue = int.parse(fees);

      final balance = await getIt
          .get<TonWalletsRepository>()
          .getInfo(address)
          .then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

      if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

      return Tuple2(unsignedMessage, fees);
    });
  }
}
