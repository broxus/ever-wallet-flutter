import 'dart:async';
import 'dart:convert';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../custom_in_app_web_view_controller.dart';

Future<dynamic> disconnectHandler({
  required CustomInAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final currentOrigin = await controller.controller.getUrl().then((v) => v?.authority);

    if (currentOrigin == null) throw Exception();

    await getIt.get<PermissionsRepository>().deletePermissions(currentOrigin);

    getIt.get<GenericContractsRepository>().clear();

    final jsonOutput = jsonEncode({});

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
