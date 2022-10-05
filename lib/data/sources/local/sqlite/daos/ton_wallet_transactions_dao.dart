import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_transactions.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' as nt;

part 'ton_wallet_transactions_dao.g.dart';

@DriftAccessor(tables: [TonWalletTransactions])
class TonWalletTransactionsDao extends DatabaseAccessor<SqliteDatabase>
    with _$TonWalletTransactionsDaoMixin {
  TonWalletTransactionsDao(super.db);

  Stream<List<nt.TransactionWithData<nt.TransactionAdditionalInfo?>>> transactions({
    required int networkId,
    required String group,
    required String address,
  }) =>
      (select(tonWalletTransactions)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) & t.group.equals(group) & t.address.equals(address),
            ))
          .watch()
          .map(
            (e) => e
                .map(
                  (e) => nt.TransactionWithData<nt.TransactionAdditionalInfo?>.fromJson(
                    jsonDecode(e.transaction) as Map<String, dynamic>,
                    (json) => json != null
                        ? nt.TransactionAdditionalInfo.fromJson(
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
    required String address,
    required List<nt.TransactionWithData<nt.TransactionAdditionalInfo?>> transactions,
  }) =>
      batch(
        (batch) => batch.insertAllOnConflictUpdate(
          tonWalletTransactions,
          transactions.map(
            (e) => TonWalletTransactionsCompanion.insert(
              lt: e.transaction.id.lt,
              networkId: networkId,
              group: group,
              address: address,
              transaction: jsonEncode(e.toJson((v) => v?.toJson())),
            ),
          ),
        ),
      );

  Future<int> deleteTransactions(String address) =>
      (delete(tonWalletTransactions)..where((t) => t.address.equals(address))).go();
}
