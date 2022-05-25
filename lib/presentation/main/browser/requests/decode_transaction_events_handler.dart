import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/decode_transaction_events_input.dart';
import 'models/decode_transaction_events_output.dart';

Future<Map<String, dynamic>?> decodeTransactionEventsHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('decodeTransactionEvents', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = DecodeTransactionEventsInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final events = decodeTransactionEvents(
      transaction: input.transaction,
      contractAbi: input.abi,
    );

    final output = DecodeTransactionEventsOutput(
      events: events,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('decodeTransactionEvents', err, st);
    rethrow;
  }
}
