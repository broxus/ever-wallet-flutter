import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/approvals_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../extensions.dart';
import 'models/sign_data_input.dart';

Future<Map<String, dynamic>> signDataHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('signData', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = SignDataInput.fromJson(jsonInput);

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

    final signedData = await getIt.get<KeysRepository>().signData(
          data: input.data,
          publicKey: input.publicKey,
          password: password,
        );

    final jsonOutput = signedData.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('signData', err, st);
    rethrow;
  }
}
