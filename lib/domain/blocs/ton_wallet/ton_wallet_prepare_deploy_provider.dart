import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../data/exceptions.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

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
      final tonWallet = await getIt
          .get<NekotonService>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TonWalletNotFoundException(),
          );

      late final UnsignedMessage message;

      if (custodians != null && reqConfirms != null) {
        message = await tonWallet.prepareDeployWithMultipleOwners(
          expiration: kDefaultMessageExpiration,
          custodians: custodians,
          reqConfirms: reqConfirms,
        );
      } else {
        message = await tonWallet.prepareDeploy(kDefaultMessageExpiration);
      }

      final fees = await tonWallet.estimateFees(message);
      final feesValue = int.parse(fees);

      final balance = await tonWallet.contractState.then((value) => value.balance);
      final balanceValue = int.parse(balance);

      final isPossibleToSendMessage = balanceValue > feesValue;

      if (isPossibleToSendMessage) {
        return Tuple2(message, fees);
      } else {
        throw InsufficientFundsException();
      }
    });
  }
}
