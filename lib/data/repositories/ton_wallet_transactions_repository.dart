import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../dtos/ton_wallet_transaction_with_data_dto.dart';
import '../sources/local/hive_source.dart';

@lazySingleton
class TonWalletTransactionsRepository {
  final HiveSource _hiveSource;

  TonWalletTransactionsRepository(this._hiveSource);

  List<TonWalletTransactionWithData>? get(String address) =>
      _hiveSource.getTonWalletTransactions(address)?.map((e) => e.toModel()).toList();

  Future<void> save({
    required List<TonWalletTransactionWithData> tonWalletTransactions,
    required String address,
  }) =>
      _hiveSource.saveTonWalletTransactions(
        tonWalletTransactions: tonWalletTransactions.map((e) => e.toDto()).toList(),
        address: address,
      );

  Future<void> remove(String address) => _hiveSource.removeTonWalletTransactions(address);

  Future<void> clear() => _hiveSource.clearTonWalletTransactions();
}
