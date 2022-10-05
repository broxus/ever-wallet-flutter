import 'package:drift/drift.dart';

@DataClassName('TonWalletDetailsEntry')
class TonWalletDetails extends Table {
  IntColumn get networkId => integer()();
  TextColumn get group => text()();
  TextColumn get address => text()();

  TextColumn get contractState => text().nullable()();
  TextColumn get details => text().nullable()();
  TextColumn get custodians => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {networkId, group, address};
}
