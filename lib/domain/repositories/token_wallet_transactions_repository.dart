import 'package:nekoton_flutter/nekoton_flutter.dart';

abstract class TokenWalletTransactionsRepository {
  List<TokenWalletTransactionWithData>? get({
    required String owner,
    required String rootTokenContract,
  });

  Future<void> save({
    required List<TokenWalletTransactionWithData> tokenWalletTransactions,
    required String owner,
    required String rootTokenContract,
  });

  Future<void> remove({
    required String owner,
    required String rootTokenContract,
  });

  Future<void> clear();
}
