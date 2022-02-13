import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/ton_wallets_subscriptions_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final tonWalletMultisigPendingTransactionsProvider = StreamProvider.family<List<MultisigPendingTransaction>, String>(
  (ref, address) {
    final stream = getIt
        .get<TonWalletsSubscriptionsRepository>()
        .tonWalletsStream
        .expand((e) => e)
        .where((e) => e.address == address);

    return Rx.combineLatest2<TonWallet, ContractState?, TonWallet>(
      stream,
      stream
          .flatMap((e) => e.onStateChangedStream)
          .cast<OnStateChangedPayload?>()
          .map((e) => e?.newState)
          .startWith(null),
      (a, b) => a,
    ).asyncMap((e) => e.unconfirmedTransactions).startWith([]).doOnError((err, st) => logger.e(err, err, st));
  },
);
