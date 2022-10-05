import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/token_wallet_details.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' as nt;

part 'token_wallet_details_dao.g.dart';

@DriftAccessor(tables: [TokenWalletDetails])
class TokenWalletDetailsDao extends DatabaseAccessor<SqliteDatabase>
    with _$TokenWalletDetailsDaoMixin {
  TokenWalletDetailsDao(super.db);

  Future<nt.Symbol?> symbol({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
  }) =>
      (select(tokenWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) &
                  t.group.equals(group) &
                  t.owner.equals(owner) &
                  t.rootTokenContract.equals(rootTokenContract),
            ))
          .map(
            (e) => e.symbol != null
                ? nt.Symbol.fromJson(jsonDecode(e.symbol!) as Map<String, dynamic>)
                : null,
          )
          .getSingleOrNull();

  Future<int> updateSymbol({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
    required nt.Symbol symbol,
  }) =>
      into(tokenWalletDetails).insertOnConflictUpdate(
        TokenWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          owner: owner,
          rootTokenContract: rootTokenContract,
          symbol: Value(jsonEncode(symbol.toJson())),
        ),
      );

  Future<nt.TokenWalletVersion?> version({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
  }) =>
      (select(tokenWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) &
                  t.group.equals(group) &
                  t.owner.equals(owner) &
                  t.rootTokenContract.equals(rootTokenContract),
            ))
          .map((e) => nt.TokenWalletVersion.values.firstWhere((el) => el.toString() == e.version))
          .getSingleOrNull();

  Future<int> updateVersion({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
    required nt.TokenWalletVersion version,
  }) =>
      into(tokenWalletDetails).insertOnConflictUpdate(
        TokenWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          owner: owner,
          rootTokenContract: rootTokenContract,
          version: Value(version.toString()),
        ),
      );

  Future<String?> balance({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
  }) =>
      (select(tokenWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) &
                  t.group.equals(group) &
                  t.owner.equals(owner) &
                  t.rootTokenContract.equals(rootTokenContract),
            ))
          .map((e) => e.balance)
          .getSingleOrNull();

  Future<int> updateBalance({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
    required String balance,
  }) =>
      into(tokenWalletDetails).insertOnConflictUpdate(
        TokenWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          owner: owner,
          rootTokenContract: rootTokenContract,
          balance: Value(balance),
        ),
      );

  Future<nt.ContractState?> contractState({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
  }) =>
      (select(tokenWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) &
                  t.group.equals(group) &
                  t.owner.equals(owner) &
                  t.rootTokenContract.equals(rootTokenContract),
            ))
          .map(
            (e) => e.contractState != null
                ? nt.ContractState.fromJson(jsonDecode(e.contractState!) as Map<String, dynamic>)
                : null,
          )
          .getSingleOrNull();

  Future<int> updateContractState({
    required int networkId,
    required String group,
    required String owner,
    required String rootTokenContract,
    required nt.ContractState contractState,
  }) =>
      into(tokenWalletDetails).insertOnConflictUpdate(
        TokenWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          owner: owner,
          rootTokenContract: rootTokenContract,
          contractState: Value(jsonEncode(contractState.toJson())),
        ),
      );

  Future<int> deleteEntries({
    required String owner,
    required String rootTokenContract,
  }) =>
      (delete(tokenWalletDetails)
            ..where((t) => t.owner.equals(owner) & t.rootTokenContract.equals(rootTokenContract)))
          .go();
}
