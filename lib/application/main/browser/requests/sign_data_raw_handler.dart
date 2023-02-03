import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/sign_data_raw_input.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> signDataRawHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required TransportSource transportSource,
  required KeysRepository keysRepository,
}) async {
  try {
    logger.d('signDataRaw', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SignDataRawInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.publicKey != input.publicKey) {
      throw Exception('Specified signer is not allowed');
    }

    final password = await approvalsRepository.signData(
      origin: origin,
      publicKey: input.publicKey,
      data: input.data,
    );

    final signatureId = await transportSource.transport.getSignatureId();

    final signedDataRaw = await keysRepository.signDataRaw(
      data: input.data,
      publicKey: input.publicKey,
      password: password,
      signatureId: signatureId,
    );

    final jsonOutput = signedDataRaw.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('signDataRaw', err, st);
    rethrow;
  }
}
