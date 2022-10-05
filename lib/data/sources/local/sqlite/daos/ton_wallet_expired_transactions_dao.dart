import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ever_wallet/data/models/pending_transaction_with_additional_info.dart' as pt;
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_expired_transactions.dart';

part 'ton_wallet_expired_transactions_dao.g.dart';

@DriftAccessor(tables: [TonWalletExpiredTransactions])
class TonWalletExpiredTransactionsDao extends DatabaseAccessor<SqliteDatabase>
    with _$TonWalletExpiredTransactionsDaoMixin {
  TonWalletExpiredTransactionsDao(super.db);

  Stream<List<pt.PendingTransactionWithAdditionalInfo>> transactions({
    required int networkId,
    required String group,
    required String address,
  }) =>
      (select(tonWalletExpiredTransactions)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) & t.group.equals(group) & t.address.equals(address),
            ))
          .watch()
          .map(
            (e) => e
                .map(
                  (e) => pt.PendingTransactionWithAdditionalInfo.fromJson(
                    jsonDecode(e.transaction) as Map<String, dynamic>,
                  ),
                )
                .toList(),
          );

  Future<int> insertTransaction({
    required int networkId,
    required String group,
    required String address,
    required pt.PendingTransactionWithAdditionalInfo transaction,
  }) =>
      into(tonWalletExpiredTransactions).insert(
        TonWalletExpiredTransactionsCompanion.insert(
          networkId: networkId,
          group: group,
          address: address,
          transaction: jsonEncode(transaction.toJson()),
        ),
      );

  Future<int> deleteTransactions(String address) =>
      (delete(tonWalletExpiredTransactions)..where((t) => t.address.equals(address))).go();
}
