import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/code_to_tvc_input.dart';
import 'models/code_to_tvc_output.dart';

Future<Map<String, dynamic>> codeToTvcHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('codeToTvc', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = CodeToTvcInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final tvc = codeToTvc(input.code);

    final output = CodeToTvcOutput(
      tvc: tvc,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('codeToTvc', err, st);
    rethrow;
  }
}
