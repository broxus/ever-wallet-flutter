import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/repositories/ton_wallet_transactions_repository.dart';
import '../dtos/ton_wallet_transaction_with_data_dto.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: TonWalletTransactionsRepository)
class TonWalletTransactionsRepositoryImpl implements TonWalletTransactionsRepository {
  final HiveSource _hiveSource;

  TonWalletTransactionsRepositoryImpl(this._hiveSource);

  @override
  List<TonWalletTransactionWithData>? get(String address) =>
      _hiveSource.getTonWalletTransactions(address)?.map((e) => e.toModel()).toList();

  @override
  Future<void> save({
    required List<TonWalletTransactionWithData> tonWalletTransactions,
    required String address,
  }) =>
      _hiveSource.saveTonWalletTransactions(
        tonWalletTransactions: tonWalletTransactions.map((e) => e.toDto()).toList(),
        address: address,
      );

  @override
  Future<void> remove(String address) => _hiveSource.removeTonWalletTransactions(address);

  @override
  Future<void> clear() => _hiveSource.clearTonWalletTransactions();
}
