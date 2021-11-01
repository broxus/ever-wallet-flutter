import 'package:nekoton_flutter/nekoton_flutter.dart';

abstract class TonWalletTransactionsRepository {
  List<TonWalletTransactionWithData>? get(String address);

  Future<void> save({
    required List<TonWalletTransactionWithData> tonWalletTransactions,
    required String address,
  });

  Future<void> remove(String address);

  Future<void> clear();
}
