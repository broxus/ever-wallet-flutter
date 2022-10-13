import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_expected_address_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_expected_address_output.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> getExpectedAddressHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
}) async {
  try {
    logger.d('getExpectedAddress', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = GetExpectedAddressInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.basic == null) throw Exception('Basic interaction not permitted');

    final address = getExpectedAddress(
      tvc: input.tvc,
      contractAbi: input.abi,
      workchainId: input.workchain ?? kDefaultWorkchain,
      publicKey: input.publicKey,
      initData: input.initParams,
    );

    final output = GetExpectedAddressOutput(address: address.item1);

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getExpectedAddress', err, st);
    rethrow;
  }
}
