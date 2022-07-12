import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_transactions_input.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> getTransactionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
}) async {
  try {
    logger.d('getTransactions', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetTransactionsInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await transportRepository.transport;

    final transactionsList = await transport.getTransactions(
      address: input.address,
      fromLt: input.continuation?.lt,
      limit: input.limit ?? 50,
    );

    final jsonOutput = transactionsList.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getTransactions', err, st);
    rethrow;
  }
}
