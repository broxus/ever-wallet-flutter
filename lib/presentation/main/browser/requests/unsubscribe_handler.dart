import 'dart:async';
import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../injection.dart';
import '../custom_in_app_web_view_controller.dart';

Future<dynamic> unsubscribeHandler({
  required CustomInAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final jsonInput = args.first as Map<String, dynamic>;

    final input = UnsubscribeInput.fromJson(jsonInput);

    if (!validateAddress(input.address)) throw Exception();

    getIt.get<GenericContractsRepository>().unsubscribe(input.address);

    final jsonOutput = jsonEncode({});

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
