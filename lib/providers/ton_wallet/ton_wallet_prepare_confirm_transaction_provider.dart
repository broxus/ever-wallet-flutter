import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';
import '../../generated/codegen_loader.g.dart';

final tonWalletPrepareConfirmTransactionProvider = StateNotifierProvider.autoDispose<
    TonWalletPrepareConfirmTransactionNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareConfirmTransactionNotifier(),
);

class TonWalletPrepareConfirmTransactionNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  UnsignedMessage? _message;

  TonWalletPrepareConfirmTransactionNotifier() : super(const AsyncValue.loading());

  @override
  void dispose() {
    _message?.freePtr();
    super.dispose();
  }

  Future<void> prepareConfirmTransaction({
    required String publicKey,
    required String address,
    required String transactionId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _message?.freePtr();

      final message = await getIt.get<TonWalletsRepository>().prepareConfirmTransaction(
            address: address,
            publicKey: publicKey,
            transactionId: transactionId,
          );

      _message = message;

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            message: message,
          );
      final feesValue = int.parse(fees);

      final balance = await getIt.get<TonWalletsRepository>().getInfo(address).then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > feesValue;

      if (!isPossibleToSendMessage) throw Exception(LocaleKeys.insufficient_funds.tr());

      return Tuple2(message, fees);
    });
  }
}
