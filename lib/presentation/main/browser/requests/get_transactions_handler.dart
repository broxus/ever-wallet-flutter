import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';

Future<dynamic> getTransactionsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('GetTransactionsRequest', args);

    final jsonInput = args.first as Map<String, dynamic>;

    final input = GetTransactionsInput.fromJson(jsonInput);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = await getIt.get<TransportRepository>().transport;

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final output = await transport.getTransactions(
      address: input.address,
      continuation: input.continuation,
      limit: input.limit,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
