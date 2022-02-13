import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/ton_wallets_subscriptions_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final tonWalletExpiredTransactionsProvider = StreamProvider.family<List<PendingTransaction>, String>(
  (ref, address) => getIt
      .get<TonWalletsSubscriptionsRepository>()
      .tonWalletsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .flatMap((e) => e.expiredTransactionsStream)
      .doOnError((err, st) => logger.e(err, err, st)),
);
