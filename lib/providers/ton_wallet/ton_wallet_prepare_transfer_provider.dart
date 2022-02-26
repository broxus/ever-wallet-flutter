import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

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
      final repackedDestination = repackAddress(destination);

      final amountValue = int.parse(amount);

      final message = await getIt.get<TonWalletsRepository>().prepareTransfer(
            address: address,
            publicKey: publicKey,
            destination: repackedDestination,
            amount: amount,
            body: body,
          );

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            message: message,
          );
      final feesValue = int.parse(fees);

      final balance =
          await getIt.get<TonWalletsRepository>().getInfoStream(address).first.then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

      if (isPossibleToSendMessage) {
        return Tuple2(message, fees);
      } else {
        throw Exception();
      }
    });
  }
}
