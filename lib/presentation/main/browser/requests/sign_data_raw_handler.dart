import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/approvals_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../extensions.dart';
import 'models/sign_data_raw_input.dart';

Future<Map<String, dynamic>> signDataRawHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('signDataRaw', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SignDataRawInput.fromJson(jsonInput);

    final origin = await controller.getOrigin();

    final existingPermissions = getIt.get<PermissionsRepository>().permissions[origin];

    if (existingPermissions?.accountInteraction == null) throw Exception('Account interaction not permitted');

    if (existingPermissions?.accountInteraction?.publicKey != input.publicKey) {
      throw Exception('Specified signer is not allowed');
    }

    final password = await getIt.get<ApprovalsRepository>().signData(
          origin: origin,
          publicKey: input.publicKey,
          data: input.data,
        );

    final signedDataRaw = await getIt.get<KeysRepository>().signDataRaw(
          data: input.data,
          publicKey: input.publicKey,
          password: password,
        );

    final jsonOutput = signedDataRaw.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('signDataRaw', err, st);
    rethrow;
  }
}
