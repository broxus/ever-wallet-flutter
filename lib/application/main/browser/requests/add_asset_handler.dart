import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/add_asset_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/add_asset_output.dart';
import 'package:ever_wallet/data/models/asset_type.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> addAssetHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
  required AccountsRepository accountsRepository,
  required ApprovalsRepository approvalsRepository,
}) async {
  try {
    logger.d('addAsset', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = AddAssetInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.address != input.account) {
      throw Exception('Specified account is not allowed');
    }

    bool newAsset;

    switch (input.type) {
      case AssetType.tip3Token:
        final rootTokenContract = repackAddress(input.params.rootContract);

        final transport = transportRepository.transport;

        final hasTokenWallet = accountsRepository.accounts
                .firstWhere((e) => e.address == input.account)
                .additionalAssets[transport.group]
                ?.tokenWallets
                .any((e) => e.rootTokenContract == rootTokenContract) ??
            false;

        if (hasTokenWallet) {
          newAsset = false;
          break;
        }

        final details = await getTokenRootDetails(
          transport: transport,
          rootTokenContract: rootTokenContract,
        );

        await approvalsRepository.addTip3Token(
          origin: origin,
          account: input.account,
          details: details,
        );

        await accountsRepository.addTokenWallet(
          address: input.account,
          rootTokenContract: rootTokenContract,
        );

        newAsset = true;
        break;
      default:
        throw Exception('Unknown asset type');
    }

    final output = AddAssetOutput(
      newAsset: newAsset,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('addAsset', err, st);
    rethrow;
  }
}
