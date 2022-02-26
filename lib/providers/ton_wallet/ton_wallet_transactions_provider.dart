import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletTransactionsProvider = StreamProvider.family<List<TonWalletTransactionWithData>, String>(
  (ref, address) =>
      getIt.get<TonWalletsRepository>().getTransactionsStream(address).doOnError((err, st) => logger.e(err, err, st)),
);
