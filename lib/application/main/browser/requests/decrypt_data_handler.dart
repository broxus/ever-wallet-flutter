import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/decrypt_data_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/decrypt_data_output.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> decryptDataHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required KeysRepository keysRepository,
}) async {
  try {
    logger.d('decryptData', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = DecryptDataInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.publicKey !=
        input.encryptedData.recipientPublicKey) {
      throw Exception('Specified encryptor public key is not allowed');
    }

    checkPublicKey(input.encryptedData.sourcePublicKey);

    final password = await approvalsRepository.decryptData(
      origin: origin,
      publicKey: input.encryptedData.recipientPublicKey,
      sourcePublicKey: input.encryptedData.sourcePublicKey,
    );

    final data = await keysRepository.decrypt(
      data: input.encryptedData,
      publicKey: input.encryptedData.recipientPublicKey,
      password: password,
    );

    final output = DecryptDataOutput(data: data);

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('decryptData', err, st);
    rethrow;
  }
}
