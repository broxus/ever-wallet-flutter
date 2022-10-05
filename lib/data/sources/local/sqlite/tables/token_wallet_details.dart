import 'package:drift/drift.dart';

@DataClassName('TokenWalletDetailsEntry')
class TokenWalletDetails extends Table {
  IntColumn get networkId => integer()();
  TextColumn get group => text()();
  TextColumn get owner => text()();
  TextColumn get rootTokenContract => text()();

  TextColumn get symbol => text().nullable()();
  TextColumn get version => text().nullable()();
  TextColumn get balance => text().nullable()();
  TextColumn get contractState => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {networkId, group, owner, rootTokenContract};
}
