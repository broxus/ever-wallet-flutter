import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/repositories/token_wallet_transactions_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tokenWalletTransactionsProvider =
    StreamProvider.family<List<TokenWalletTransactionWithData>, Tuple2<String, String>>((ref, params) {
  final owner = params.item1;
  final rootTokenContract = params.item2;

  final stream = getIt
      .get<NekotonService>()
      .tokenWalletsStream
      .expand((e) => e)
      .where((e) => e.owner == owner && e.symbol.rootTokenContract == rootTokenContract)
      .flatMap((e) => e.transactionsStream)
      .map((e) => e.where((e) => e.data != null).toList());

  final cached = getIt.get<TokenWalletTransactionsRepository>().get(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  return stream.asyncMap(
    (e) async {
      await getIt.get<TokenWalletTransactionsRepository>().save(
            tokenWalletTransactions: e,
            owner: owner,
            rootTokenContract: rootTokenContract,
          );

      return e;
    },
  ).startWith(cached);
});
