import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/token_wallets_repository.dart';

final tokenWalletTransactionsProvider =
    StreamProvider.family<List<TokenWalletTransactionWithData>, Tuple2<String, String>>(
  (ref, params) => getIt
      .get<TokenWalletsRepository>()
      .getTransactionsStream(owner: params.item1, rootTokenContract: params.item2)
      .doOnError((err, st) => logger.e(err, err, st)),
);
