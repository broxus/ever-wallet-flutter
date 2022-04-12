import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';
import '../../generated/codegen_loader.g.dart';

final tonWalletPrepareDeployProvider =
    StateNotifierProvider.autoDispose<TonWalletPrepareDeployNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => TonWalletPrepareDeployNotifier(),
);

class TonWalletPrepareDeployNotifier extends StateNotifier<AsyncValue<Tuple2<UnsignedMessage, String>>> {
  UnsignedMessage? _message;

  TonWalletPrepareDeployNotifier() : super(const AsyncValue.loading());

  @override
  void dispose() {
    _message?.freePtr();
    super.dispose();
  }

  Future<void> prepareDeploy({
    required String address,
    List<String>? custodians,
    int? reqConfirms,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _message?.freePtr();

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
