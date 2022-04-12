import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../data/repositories/keys_repository.dart';
import '../../../data/repositories/ton_wallets_repository.dart';
import '../../../generated/codegen_loader.g.dart';
import '../../../injection.dart';

Future<List<String>> getLocalCustodiansPublicKeys(String address) async {
  final tonWalletInfo = await getIt.get<TonWalletsRepository>().getInfo(address);

  final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;
  final isDeployed = tonWalletInfo.contractState.isDeployed;

  if (requiresSeparateDeploy && !isDeployed) throw Exception(LocaleKeys.wallet_not_deployed.tr());

  if (!requiresSeparateDeploy) return [tonWalletInfo.publicKey];

  final custodians = tonWalletInfo.custodians!;

  final keys = getIt.get<KeysRepository>().keys;

  final localCustodians = keys.where((e) => custodians.any((el) => el == e.publicKey)).toList();

  final currentKey = getIt.get<KeysRepository>().currentKey;

  final initiatorKey = localCustodians.firstWhereOrNull((e) => e == currentKey);

  final list = [
    if (initiatorKey != null) initiatorKey,
    ...localCustodians.where((e) => e != initiatorKey),
  ].map((e) => e.publicKey).toList();

  return list;
}
