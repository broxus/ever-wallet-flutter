import 'package:injectable/injectable.dart';

import '../../domain/models/ton_wallet_transactions.dart';
import '../../domain/repositories/ton_wallet_transactions_repository.dart';
import '../dtos/ton_wallet_transactions_dto.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: TonWalletTransactionsRepository)
class TonWalletTransactionsRepositoryImpl implements TonWalletTransactionsRepository {
  final HiveSource _hiveSource;

  TonWalletTransactionsRepositoryImpl(this._hiveSource);

  @override
  TonWalletTransactions? get(String address) => _hiveSource.getTonWalletTransactions(address)?.toModel();

  @override
  Future<void> save({
    required String address,
    required TonWalletTransactions tonWalletTransactions,
  }) =>
      _hiveSource.saveTonWalletTransactions(
        tonWalletTransactions: tonWalletTransactions.toDto(),
        address: address,
      );

  @override
  Future<void> remove(String address) => _hiveSource.removeTonWalletTransactions(address);

  @override
  Future<void> clear() => _hiveSource.clearTonWalletTransactions();
}
