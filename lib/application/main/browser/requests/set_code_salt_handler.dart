import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/set_code_salt_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/set_code_salt_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> setCodeSaltHandler({
  required InAppWebViewController controller,
  required PermissionsRepository permissionsRepository,
  required List<dynamic> args,
}) async {
  try {
    logger.d('setCodeSalt', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SetCodeSaltInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final code = setCodeSalt(code: input.code, salt: input.salt);

    final output = SetCodeSaltOutput(
      code: code,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('setCodeSalt', err, st);
    rethrow;
  }
}
