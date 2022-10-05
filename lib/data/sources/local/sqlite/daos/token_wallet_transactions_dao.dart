import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/token_wallet_transactions.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' as nt;

part 'token_wallet_transactions_dao.g.dart';

@DriftAccessor(tables: [TokenWalletTransactions])
class TokenWalletTransactionsDao extends DatabaseAccessor<SqliteDatabase>
    with _$TokenWalletTransactionsDaoMixin {
  TokenWalletTransactionsDao(super.db);

  Stream<List<nt.TransactionWithData<nt.TokenWalletTransaction?>>> transactions({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
  }) =>
      (select(tokenWalletTransactions)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) &
                  t.group.equals(group) &
                  t.owner.equals(owner) &
                  t.rootTokenContract.equals(rootTokenContract),
            ))
          .watch()
          .map(
            (e) => e
                .map(
                  (e) => nt.TransactionWithData<nt.TokenWalletTransaction?>.fromJson(
                    jsonDecode(e.transaction) as Map<String, dynamic>,
                    (json) => json != null
                        ? nt.TokenWalletTransaction.fromJson(
                            json as Map<String, dynamic>,
                          )
                        : null,
                  ),
                )
                .toList(),
          );

  Future<void> insertTransactions({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
    required List<nt.TransactionWithData<nt.TokenWalletTransaction?>> transactions,
  }) =>
      batch(
        (batch) => batch.insertAllOnConflictUpdate(
          tokenWalletTransactions,
          transactions.map(
            (e) => TokenWalletTransactionsCompanion.insert(
              lt: e.transaction.id.lt,
              networkId: networkId,
              group: group,
              owner: owner,
              rootTokenContract: rootTokenContract,
              transaction: jsonEncode(e.toJson((v) => v?.toJson())),
            ),
          ),
        ),
      );

  Future<int> deleteTransactions({
    required String owner,
    required String rootTokenContract,
  }) =>
      (delete(tokenWalletTransactions)
            ..where((t) => t.owner.equals(owner) & t.rootTokenContract.equals(rootTokenContract)))
          .go();
}
