import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';
import '../../generated/codegen_loader.g.dart';

final tonWalletPrepareTransferProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareTransferNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareTransferNotifier(),
);

class TonWalletPrepareTransferNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  UnsignedMessage? _unsignedMessage;

  TonWalletPrepareTransferNotifier() : super(const AsyncValue.loading());

  @override
  void dispose() {
    _unsignedMessage?.freePtr();
    super.dispose();
  }

  Future<void> prepareTransfer({
    required String address,
    String? publicKey,
    required String destination,
    required String amount,
    String? body,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _unsignedMessage?.freePtr();

      final repackedDestination = repackAddress(destination);

      final amountValue = int.parse(amount);

      final unsignedMessage = await getIt.get<TonWalletsRepository>().prepareTransfer(
            address: address,
            publicKey: publicKey,
            destination: repackedDestination,
            amount: amount,
            body: body,
          );

      _unsignedMessage = unsignedMessage;

      await unsignedMessage.refreshTimeout();

      final signature = base64.encode(List.generate(kSignatureLength, (_) => 0));

      final signedMessage = await unsignedMessage.sign(signature);

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            signedMessage: signedMessage,
          );
      final feesValue = int.parse(fees);

      final balance = await getIt.get<TonWalletsRepository>().getInfo(address).then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

      if (!isPossibleToSendMessage) throw Exception(LocaleKeys.insufficient_funds.tr());

      return Tuple2(unsignedMessage, fees);
    });
  }
}
