import 'package:drift/drift.dart';

class TokenWalletTransactions extends Table {
  TextColumn get lt => text()();

  IntColumn get networkId => integer()();
  TextColumn get group => text()();
  TextColumn get owner => text()();
  TextColumn get rootTokenContract => text()();

  TextColumn get transaction => text()();

  @override
  Set<Column<Object>>? get primaryKey => {lt};
}
