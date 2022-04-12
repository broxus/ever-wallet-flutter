import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../injection.dart';

Future<dynamic> unsubscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('UnsubscribeRequest', args);

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
