import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/get_transaction_input.dart';
import 'models/get_transaction_output.dart';

Future<Map<String, dynamic>> getTransactionHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('getTransaction', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetTransactionInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await getIt.get<TransportRepository>().transport;

    final transaction = await transport.getTransaction(input.hash);

    final output = GetTransactionOutput(
      transaction: transaction,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getTransaction', err, st);
    rethrow;
  }
}
