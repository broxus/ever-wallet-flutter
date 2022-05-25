import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/get_transactions_input.dart';

Future<Map<String, dynamic>> getTransactionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('getTransactions', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetTransactionsInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await getIt.get<TransportRepository>().transport;

    final transactionsList = await transport.getTransactions(
      address: input.address,
      continuation: input.continuation,
      limit: input.limit ?? 50,
    );

    final jsonOutput = transactionsList.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getTransactions', err, st);
    rethrow;
  }
}
