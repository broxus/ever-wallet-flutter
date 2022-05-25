import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';
import 'models/unpack_from_cell_input.dart';
import 'models/unpack_from_cell_output.dart';

Future<Map<String, dynamic>> unpackFromCellHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('unpackFromCell', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = UnpackFromCellInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final data = unpackFromCell(
      params: input.structure,
      boc: input.boc,
      allowPartial: input.allowPartial,
    );

    final output = UnpackFromCellOutput(
      data: data,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('unpackFromCell', err, st);
    rethrow;
  }
}
