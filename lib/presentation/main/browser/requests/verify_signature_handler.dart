import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/verify_signature_input.dart';
import 'models/verify_signature_output.dart';

Future<Map<String, dynamic>> verifySignatureHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('verifySignature', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = VerifySignatureInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

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
