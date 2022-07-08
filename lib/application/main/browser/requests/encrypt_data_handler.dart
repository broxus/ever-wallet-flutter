import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/encrypt_data_input.dart';
import 'package:ever_wallet/application/main/browser/requests/models/encrypt_data_output.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> encryptDataHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required PermissionsRepository permissionsRepository,
  required ApprovalsRepository approvalsRepository,
  required KeysRepository keysRepository,
}) async {
  try {
    logger.d('encryptData', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = EncryptDataInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = permissionsRepository.permissions[origin];

    if (existingPermissions?.accountInteraction == null) {
      throw Exception('Account interaction not permitted');
    }

    if (existingPermissions?.accountInteraction?.publicKey != input.publicKey) {
      throw Exception('Specified encryptor public key is not allowed');
    }

    final password = await approvalsRepository.encryptData(
      origin: origin,
      publicKey: input.publicKey,
      data: input.data,
    );

    final encryptedData = await keysRepository.encrypt(
      data: input.data,
      publicKeys: input.recipientPublicKeys,
      algorithm: input.algorithm,
      publicKey: input.publicKey,
      password: password,
    );

    final output = EncryptDataOutput(encryptedData: encryptedData);

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('encryptData', err, st);
    rethrow;
  }
}
