import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_full_contract_state_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_full_contract_state_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> getFullContractStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
}) async {
  try {
    logger.d('getFullContractState', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetFullContractStateInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = transportRepository.transport;

    final fullContractState = await transport.getFullContractState(input.address);

    final output = GetFullContractStateOutput(
      state: fullContractState,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getFullContractState', err, st);
    rethrow;
  }
}
