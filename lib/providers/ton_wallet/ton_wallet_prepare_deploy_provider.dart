import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletPrepareDeployProvider = StateNotifierProvider.autoDispose<
    TonWalletPrepareDeployNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareDeployNotifier(),
);

class TonWalletPrepareDeployNotifier
    extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  TonWalletPrepareDeployNotifier() : super(const AsyncValue.loading());

  Future<void> prepareDeploy({
    required String address,
    List<String>? custodians,
    int? reqConfirms,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      late final UnsignedMessage unsignedMessage;

      if (custodians != null && reqConfirms != null) {
        unsignedMessage = await getIt.get<TonWalletsRepository>().prepareDeployWithMultipleOwners(
              address: address,
              custodians: custodians,
              reqConfirms: reqConfirms,
            );
      } else {
        unsignedMessage = await getIt.get<TonWalletsRepository>().prepareDeploy(address);
      }

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

      final isPossibleToSendMessage = balanceValue > feesValue;

      if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

      return Tuple2(unsignedMessage, fees);
    });
  }
}
