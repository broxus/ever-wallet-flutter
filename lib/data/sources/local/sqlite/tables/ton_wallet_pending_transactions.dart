import 'package:drift/drift.dart';

class TonWalletPendingTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get networkId => integer()();
  TextColumn get group => text()();
  TextColumn get address => text()();

  TextColumn get transaction => text()();
}
