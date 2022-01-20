import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/ton_wallet_transactions_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletTransactionsProvider = StreamProvider.family<List<TonWalletTransactionWithData>, String>((ref, address) {
  final stream = getIt
      .get<NekotonService>()
      .tonWalletsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .flatMap((e) => e.transactionsStream);

  final cached = getIt.get<TonWalletTransactionsRepository>().get(address);

  return stream.asyncMap(
    (e) async {
      await getIt.get<TonWalletTransactionsRepository>().save(tonWalletTransactions: e, address: address);

      return e;
    },
  ).startWith(cached);
});
