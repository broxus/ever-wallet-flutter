import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/pack_into_cell_input.dart';
import 'models/pack_into_cell_output.dart';

Future<Map<String, dynamic>> packIntoCellHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('packIntoCell', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = PackIntoCellInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final boc = packIntoCell(
      params: input.structure,
      tokens: input.data,
    );

    final output = PackIntoCellOutput(
      boc: boc,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('packIntoCell', err, st);
    rethrow;
  }
}
