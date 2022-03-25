import 'dart:async';
import 'dart:convert';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../injection.dart';
import '../custom_in_app_web_view_controller.dart';

Future<dynamic> unsubscribeAllHandler({
  required CustomInAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    getIt.get<GenericContractsRepository>().clear();

    final jsonOutput = jsonEncode({});

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
