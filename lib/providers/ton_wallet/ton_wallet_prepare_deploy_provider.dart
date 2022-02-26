import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletPrepareDeployProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareDeployNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareDeployNotifier(ref.read),
);

class TonWalletPrepareDeployNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  final Reader read;

  TonWalletPrepareDeployNotifier(this.read) : super(const AsyncValue.loading());

  Future<void> prepareDeploy({
    required String address,
    List<String>? custodians,
    int? reqConfirms,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      late final UnsignedMessage message;

      if (custodians != null && reqConfirms != null) {
        message = await getIt.get<TonWalletsRepository>().prepareDeployWithMultipleOwners(
              address: address,
              custodians: custodians,
              reqConfirms: reqConfirms,
            );
      } else {
        message = await getIt.get<TonWalletsRepository>().prepareDeploy(address);
      }

      final fees = await getIt.get<TonWalletsRepository>().estimateFees(
            address: address,
            message: message,
          );
      final feesValue = int.parse(fees);

      final balance =
          await getIt.get<TonWalletsRepository>().getInfoStream(address).first.then((v) => v.contractState.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > feesValue;

      if (isPossibleToSendMessage) {
        return Tuple2(message, fees);
      } else {
        throw Exception();
      }
    });
  }
}
