import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ever_wallet/data/sources/local/sqlite/daos/token_wallet_details_dao.dart';
import 'package:ever_wallet/data/sources/local/sqlite/daos/token_wallet_transactions_dao.dart';
import 'package:ever_wallet/data/sources/local/sqlite/daos/ton_wallet_details_dao.dart';
import 'package:ever_wallet/data/sources/local/sqlite/daos/ton_wallet_expired_transactions_dao.dart';
import 'package:ever_wallet/data/sources/local/sqlite/daos/ton_wallet_pending_transactions_dao.dart';
import 'package:ever_wallet/data/sources/local/sqlite/daos/ton_wallet_transactions_dao.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/token_wallet_details.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/token_wallet_transactions.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_details.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_expired_transactions.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_pending_transactions.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_transactions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'sqlite_database.g.dart';

@DriftDatabase(
  tables: [
    TonWalletPendingTransactions,
    TonWalletExpiredTransactions,
    TonWalletTransactions,
    TokenWalletTransactions,
    TonWalletDetails,
    TokenWalletDetails,
  ],
  daos: [
    TonWalletPendingTransactionsDao,
    TonWalletExpiredTransactionsDao,
    TonWalletTransactionsDao,
    TokenWalletTransactionsDao,
    TonWalletDetailsDao,
    TokenWalletDetailsDao,
  ],
)
class SqliteDatabase extends _$SqliteDatabase {
  SqliteDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() => LazyDatabase(() async {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(join(dbFolder.path, 'db.sqlite'));
        return NativeDatabase(file);
      });
}
