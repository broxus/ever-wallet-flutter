import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../extensions.dart';

Future<dynamic> getExpectedAddressHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('GetExpectedAddressRequest', args);

    final jsonInput = args.first as Map<String, dynamic>;

    final input = GetExpectedAddressInput.fromJson(jsonInput);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().checkPermissions(
      origin: currentOrigin,
      requiredPermissions: [Permission.basic],
    );

    final address = getExpectedAddress(
      tvc: input.tvc,
      contractAbi: input.abi,
      workchainId: input.workchain,
      publicKey: input.publicKey,
      initData: input.initParams,
    );

    final output = GetExpectedAddressOutput(
      address: address,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
