import 'dart:async';

import 'package:collection/collection.dart';

import '../../../data/repositories/keys_repository.dart';
import '../../../data/repositories/ton_wallets_repository.dart';
import '../../../injection.dart';

Future<List<String>> getLocalCustodiansPublicKeys(String address) async {
  final keys = getIt.get<KeysRepository>().keys;
  final currentKey = getIt.get<KeysRepository>().currentKey;
  final tonWalletInfo = await getIt.get<TonWalletsRepository>().getInfo(address);

  if (currentKey == null) throw Exception('No current key');

  final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;
  final isDeployed = tonWalletInfo.contractState.isDeployed;

  if (requiresSeparateDeploy && !isDeployed) throw Exception('Wallet is not deployed');

  final custodians = tonWalletInfo.custodians ?? [];

  final localCustodians = keys.where((e) => custodians.any((el) => el == e.publicKey)).toList();

  final initiatorKey = localCustodians.firstWhereOrNull((e) => e.publicKey == currentKey.publicKey);

  final list = [
    if (initiatorKey != null) initiatorKey,
    ...localCustodians.where((e) => e.publicKey != initiatorKey?.publicKey),
  ];

  return list.map((e) => e.publicKey).toList();
}
