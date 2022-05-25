import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/get_accounts_by_code_hash_input.dart';

Future<Map<String, dynamic>> getAccountsByCodeHashHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('getAccountsByCodeHash', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetAccountsByCodeHashInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await getIt.get<TransportRepository>().transport;

    final accountsList = await transport.getAccountsByCodeHash(
      codeHash: input.codeHash,
      limit: input.limit ?? 50,
      continuation: input.continuation,
    );

    final jsonOutput = accountsList.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getAccountsByCodeHash', err, st);
    rethrow;
  }
}
