import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/merge_tvc_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/merge_tvc_output.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> mergeTvcHandler({
  required InAppWebViewController controller,
  required PermissionsRepository permissionsRepository,
  required List<dynamic> args,
}) async {
  try {
    logger.d('mergeTvc', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = MergeTvcInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final tvc = mergeTvc(code: input.code, data: input.data);

    final output = MergeTvcOutput(
      tvc: tvc,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('mergeTvc', err, st);
    rethrow;
  }
}
