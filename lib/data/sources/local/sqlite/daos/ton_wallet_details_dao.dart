import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart';
import 'package:ever_wallet/data/sources/local/sqlite/tables/ton_wallet_details.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' as nt;

part 'ton_wallet_details_dao.g.dart';

@DriftAccessor(tables: [TonWalletDetails])
class TonWalletDetailsDao extends DatabaseAccessor<SqliteDatabase> with _$TonWalletDetailsDaoMixin {
  TonWalletDetailsDao(super.db);

  Future<nt.ContractState?> contractState({
    required int networkId,
    required String group,
    required String address,
  }) =>
      (select(tonWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) & t.group.equals(group) & t.address.equals(address),
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
    required String address,
    required nt.ContractState contractState,
  }) =>
      into(tonWalletDetails).insertOnConflictUpdate(
        TonWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          address: address,
          contractState: Value(jsonEncode(contractState.toJson())),
        ),
      );

  Future<nt.TonWalletDetails?> details({
    required int networkId,
    required String group,
    required String address,
  }) =>
      (select(tonWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) & t.group.equals(group) & t.address.equals(address),
            ))
          .map(
            (e) => e.details != null
                ? nt.TonWalletDetails.fromJson(jsonDecode(e.details!) as Map<String, dynamic>)
                : null,
          )
          .getSingleOrNull();

  Future<int> updateDetails({
    required int networkId,
    required String group,
    required String address,
    required nt.TonWalletDetails details,
  }) =>
      into(tonWalletDetails).insertOnConflictUpdate(
        TonWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          address: address,
          details: Value(jsonEncode(details.toJson())),
        ),
      );

  Future<List<String>?> custodians({
    required int networkId,
    required String group,
    required String address,
  }) =>
      (select(tonWalletDetails)
            ..where(
              (t) =>
                  t.networkId.equals(networkId) & t.group.equals(group) & t.address.equals(address),
            ))
          .map(
            (e) => e.custodians != null
                ? (jsonDecode(e.custodians!) as List<dynamic>).cast<String>()
                : null,
          )
          .getSingleOrNull();

  Future<int> updateCustodians({
    required int networkId,
    required String group,
    required String address,
    required List<String>? custodians,
  }) =>
      into(tonWalletDetails).insertOnConflictUpdate(
        TonWalletDetailsCompanion.insert(
          networkId: networkId,
          group: group,
          address: address,
          custodians: Value(jsonEncode(custodians)),
        ),
      );

  Future<int> deleteEntries(String address) =>
      (delete(tonWalletDetails)..where((t) => t.address.equals(address))).go();
}
