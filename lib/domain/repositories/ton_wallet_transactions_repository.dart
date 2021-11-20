import '../models/ton_wallet_transactions.dart';

abstract class TonWalletTransactionsRepository {
  TonWalletTransactions? get(String address);

  Future<void> save({
    required String address,
    required TonWalletTransactions tonWalletTransactions,
  });

  Future<void> remove(String address);

  Future<void> clear();
}
