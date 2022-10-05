import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/extensions/json1.dart';
import 'package:ever_wallet/data/models/pending_transaction_with_additional_info.dart' as pt;
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_pending_transactions.dart';

part 'ton_wallet_pending_transactions_dao.g.dart';

@DriftAccessor(tables: [TonWalletPendingTransactions])
class TonWalletPendingTransactionsDao extends DatabaseAccessor<SqliteDatabase>
    with _$TonWalletPendingTransactionsDaoMixin {
  TonWalletPendingTransactionsDao(super.db);

  Stream<List<pt.PendingTransactionWithAdditionalInfo>> transactions({
    required int networkId,
    required String group,
    required String address,
  }) =>
      (select(tonWalletPendingTransactions)
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
      into(tonWalletPendingTransactions).insert(
        TonWalletPendingTransactionsCompanion.insert(
          networkId: networkId,
          group: group,
          address: address,
          transaction: jsonEncode(transaction.toJson()),
        ),
      );

  Future<pt.PendingTransactionWithAdditionalInfo> deleteTransaction({
    required int networkId,
    required String group,
    required String address,
    required String messageHash,
  }) async {
    final entry = await (select(tonWalletPendingTransactions)
          ..where(
            (t) =>
                t.networkId.equals(networkId) &
                t.group.equals(group) &
                t.address.equals(address) &
                t.transaction.jsonExtract<String>(r'$.transaction.messageHash').equals(messageHash),
          ))
        .getSingle();

    final pendingTransaction = pt.PendingTransactionWithAdditionalInfo.fromJson(
      jsonDecode(entry.transaction) as Map<String, dynamic>,
    );

    await delete(tonWalletPendingTransactions).delete(entry);

    return pendingTransaction;
  }

  Future<int> deleteTransactions(String address) =>
      (delete(tonWalletPendingTransactions)..where((t) => t.address.equals(address))).go();
}
