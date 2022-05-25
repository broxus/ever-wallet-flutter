import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/models/asset_type.dart';
import '../../../../data/repositories/accounts_repository.dart';
import '../../../../data/repositories/approvals_repository.dart';
import '../../../../data/repositories/transport_repository.dart';
import '../extensions.dart';
import 'models/add_asset_input.dart';
import 'models/add_asset_output.dart';

Future<Map<String, dynamic>> addAssetHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('addAsset', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = AddAssetInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    if (existingPermissions?.accountInteraction?.address != input.account) {
      throw Exception('Specified account is not allowed');
    }

    bool newAsset;

    switch (input.type) {
      case AssetType.tip3Token:
        final rootTokenContract = repackAddress(input.params.rootContract);

        final transport = await getIt.get<TransportRepository>().transport;

        final hasTokenWallet = getIt
                .get<AccountsRepository>()
                .accounts
                .firstWhere((e) => e.address == input.account)
                .additionalAssets[transport.connectionData.group]
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

        await getIt.get<ApprovalsRepository>().addTip3Token(
              origin: origin,
              account: input.account,
              details: details,
            );

        await getIt.get<AccountsRepository>().addTokenWallet(
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
