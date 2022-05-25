import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/get_boc_hash_input.dart';
import 'models/get_boc_hash_output.dart';

Future<Map<String, dynamic>> getBocHashHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('getBocHash', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetBocHashInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final hash = getBocHash(input.boc);

    final output = GetBocHashOutput(
      hash: hash,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getBocHash', err, st);
    rethrow;
  }
}
