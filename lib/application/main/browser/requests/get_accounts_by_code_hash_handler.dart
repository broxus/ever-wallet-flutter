import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_accounts_by_code_hash_input.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> getAccountsByCodeHashHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
}) async {
  try {
    logger.d('getAccountsByCodeHash', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetAccountsByCodeHashInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final transport = await transportRepository.transport;

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
