import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/decode_output_input.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>?> decodeOutputHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
}) async {
  try {
    logger.d('decodeOutput', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = DecodeOutputInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final output = decodeOutput(
      messageBody: input.body,
      contractAbi: input.abi,
      method: input.method,
    );

    final jsonOutput = output?.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('decodeOutput', err, st);
    rethrow;
  }
}
