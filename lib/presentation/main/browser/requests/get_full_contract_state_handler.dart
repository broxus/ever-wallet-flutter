import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/get_full_contract_state_input.dart';
import 'models/get_full_contract_state_output.dart';

Future<Map<String, dynamic>> getFullContractStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('getFullContractState', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetFullContractStateInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await getIt.get<TransportRepository>().transport;

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
