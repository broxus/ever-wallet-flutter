import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../sources/local/hive_source.dart';

@lazySingleton
class TokenWalletTransactionsRepository {
  final HiveSource _hiveSource;

  TokenWalletTransactionsRepository(this._hiveSource);

  List<TokenWalletTransactionWithData>? get({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.getTokenWalletTransactions(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  Future<void> save({
    required List<TokenWalletTransactionWithData> tokenWalletTransactions,
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.saveTokenWalletTransactions(
        tokenWalletTransactions: tokenWalletTransactions,
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  Future<void> remove({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.removeTokenWalletTransactions(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  Future<void> clear() => _hiveSource.clearTokenWalletTransactions();
}
