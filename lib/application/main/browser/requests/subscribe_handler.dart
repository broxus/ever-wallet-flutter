import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/subscribe_input.dart';
import 'package:ever_wallet/data/models/contract_updates_subscription.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> subscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required GenericContractsRepository genericContractsRepository,
}) async {
  try {
    logger.d('subscribe', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SubscribeInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    if (!validateAddress(input.address)) throw Exception('Invalid address');

    genericContractsRepository.subscribe(input.address);

    const output = ContractUpdatesSubscription(
      state: true,
      transactions: true,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('subscribe', err, st);
    rethrow;
  }
}
