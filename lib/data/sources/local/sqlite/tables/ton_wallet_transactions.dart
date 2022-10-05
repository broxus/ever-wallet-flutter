import 'package:drift/drift.dart';

class TonWalletTransactions extends Table {
  TextColumn get lt => text()();

  IntColumn get networkId => integer()();
  TextColumn get group => text()();
  TextColumn get address => text()();

  TextColumn get transaction => text()();

  @override
  Set<Column<Object>>? get primaryKey => {lt};
}
