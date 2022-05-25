import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/run_local_input.dart';

Future<Map<String, dynamic>> runLocalHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('runLocal', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = RunLocalInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await getIt.get<TransportRepository>().transport;

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
