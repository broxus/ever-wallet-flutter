import 'package:crystal/data/dtos/token_wallet_transaction_with_data_dto.dart';
import 'package:crystal/domain/repositories/token_wallet_transactions_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../sources/local/hive_source.dart';

@LazySingleton(as: TokenWalletTransactionsRepository)
class TokenWalletTransactionsRepositoryImpl implements TokenWalletTransactionsRepository {
  final HiveSource _hiveSource;

  TokenWalletTransactionsRepositoryImpl(this._hiveSource);

  @override
  List<TokenWalletTransactionWithData>? get({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource
          .getTokenWalletTransactions(
            owner: owner,
            rootTokenContract: rootTokenContract,
          )
          ?.map((e) => e.toModel())
          .toList();

  @override
  Future<void> save({
    required List<TokenWalletTransactionWithData> tokenWalletTransactions,
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.saveTokenWalletTransactions(
        tokenWalletTransactions: tokenWalletTransactions.map((e) => e.toDto()).toList(),
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<void> remove({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.removeTokenWalletTransactions(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<void> clear() => _hiveSource.clearTokenWalletTransactions();
}
