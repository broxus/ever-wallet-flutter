import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<List<String>> getLocalCustodiansPublicKeys({
  required BuildContext context,
  required String address,
}) async {
  final keysRepo = context.read<KeysRepository>();
  final tonWalletInfo = await context.read<TonWalletsRepository>().getInfo(address);

  final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;
  final isDeployed = tonWalletInfo.contractState.isDeployed;

  if (requiresSeparateDeploy && !isDeployed) {
    throw Exception(context.localization.wallet_not_deployed);
  }

  if (!requiresSeparateDeploy) return [tonWalletInfo.publicKey];

  final custodians = tonWalletInfo.custodians!;

  final keys = keysRepo.keys;

  final localCustodians = keys.where((e) => custodians.any((el) => el == e.publicKey)).toList();

  final currentKey = keysRepo.currentKey;

  final initiatorKey = localCustodians.firstWhereOrNull((e) => e == currentKey);

  final list = [
    if (initiatorKey != null) initiatorKey,
    ...localCustodians.where((e) => e != initiatorKey),
  ].map((e) => e.publicKey).toList();

  return list;
}
