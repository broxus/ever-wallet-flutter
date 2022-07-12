import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/encode_internal_input_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/encode_internal_input_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> encodeInternalInputHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
}) async {
  try {
    logger.d('encodeInternalInput', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = EncodeInternalInputInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final boc = encodeInternalInput(
      contractAbi: input.abi,
      method: input.method,
      input: input.params,
    );

    final output = EncodeInternalInputOutput(
      boc: boc,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('encodeInternalInput', err, st);
    rethrow;
  }
}
