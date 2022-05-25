import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/approvals_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../extensions.dart';
import 'models/encrypt_data_input.dart';
import 'models/encrypt_data_output.dart';

Future<Map<String, dynamic>> encryptDataHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('encryptData', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = EncryptDataInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    if (existingPermissions?.accountInteraction?.publicKey != input.publicKey) {
      throw Exception('Specified encryptor public key is not allowed');
    }

    final password = await getIt.get<ApprovalsRepository>().encryptData(
          origin: origin,
          publicKey: input.publicKey,
          data: input.data,
        );

    final encryptedData = await getIt.get<KeysRepository>().encrypt(
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
