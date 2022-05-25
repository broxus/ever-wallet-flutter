import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/models/contract_updates_subscription.dart';
import '../extensions.dart';
import 'models/subscribe_input.dart';

Future<Map<String, dynamic>> subscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('subscribe', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SubscribeInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    if (!validateAddress(input.address)) throw Exception('Invalid address');

    getIt.get<GenericContractsRepository>().subscribe(input.address);

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
