import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';

Future<dynamic> packIntoCellHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('PackIntoCellRequest', args);

    final jsonInput = args.first as Map<String, dynamic>;

    final input = PackIntoCellInput.fromJson(jsonInput);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final boc = packIntoCell(
      params: input.structure,
      tokens: input.data,
    );

    final output = PackIntoCellOutput(
      boc: boc,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
