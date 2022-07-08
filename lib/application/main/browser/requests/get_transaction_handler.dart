import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_transaction_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_transaction_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> getTransactionHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
}) async {
  try {
    logger.d('getTransaction', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetTransactionInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await transportRepository.transport;

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
