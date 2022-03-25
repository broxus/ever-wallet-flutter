import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletExpiredTransactionsProvider = StreamProvider.autoDispose.family<List<PendingTransaction>?, String>(
  (ref, address) => getIt
      .get<TonWalletsRepository>()
      .getExpiredMessagesStream(address)
      .doOnError((err, st) => logger.e(err, err, st)),
);
