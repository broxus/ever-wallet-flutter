import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/run_local_input.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> runLocalHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
}) async {
  try {
    logger.d('runLocal', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = RunLocalInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await transportRepository.transport;

    final contractState = input.cachedState ?? await transport.getFullContractState(input.address);

    if (contractState == null) throw Exception('Account not found');

    if (!contractState.isDeployed || contractState.lastTransactionId == null) {
      throw Exception('Account is not deployed');
    }

    final executionOutput = runLocal(
      accountStuffBoc: contractState.boc,
      contractAbi: input.functionCall.abi,
      method: input.functionCall.method,
      input: input.functionCall.params,
      responsible: input.responsible ?? false,
    );

    final jsonOutput = executionOutput.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('runLocal', err, st);
    rethrow;
  }
}
