import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/extract_public_key_input.dart';
import 'models/extract_public_key_output.dart';

Future<Map<String, dynamic>> extractPublicKeyHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('extractPublicKey', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = ExtractPublicKeyInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final publicKey = extractPublicKey(input.boc);

    final output = ExtractPublicKeyOutput(
      publicKey: publicKey,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('extractPublicKey', err, st);
    rethrow;
  }
}
