import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';

Future<dynamic> encodeInternalInputHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('EncodeInternalInputRequest', args);

    final jsonInput = args.first as Map<String, dynamic>;

    final input = EncodeInternalInputInput.fromJson(jsonInput);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final boc = encodeInternalInput(
      contractAbi: input.abi,
      method: input.method,
      input: input.params,
    );

    final output = EncodeInternalInputOutput(
      boc: boc,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
