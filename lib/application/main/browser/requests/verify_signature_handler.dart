import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/verify_signature_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/verify_signature_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> verifySignatureHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
}) async {
  try {
    logger.d('verifySignature', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = VerifySignatureInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final isValid = verifySignature(
      publicKey: input.publicKey,
      dataHash: input.dataHash,
      signature: input.signature,
    );

    final output = VerifySignatureOutput(
      isValid: isValid,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('verifySignature', err, st);
    rethrow;
  }
}
