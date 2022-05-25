import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/approvals_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../extensions.dart';
import 'models/decrypt_data_input.dart';
import 'models/decrypt_data_output.dart';

Future<Map<String, dynamic>> decryptDataHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('decryptData', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = DecryptDataInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    if (existingPermissions?.accountInteraction?.publicKey != input.encryptedData.recipientPublicKey) {
      throw Exception('Specified encryptor public key is not allowed');
    }

    checkPublicKey(input.encryptedData.sourcePublicKey);

    final password = await getIt.get<ApprovalsRepository>().decryptData(
          origin: origin,
          publicKey: input.encryptedData.recipientPublicKey,
          sourcePublicKey: input.encryptedData.sourcePublicKey,
        );

    final data = await getIt.get<KeysRepository>().decrypt(
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
