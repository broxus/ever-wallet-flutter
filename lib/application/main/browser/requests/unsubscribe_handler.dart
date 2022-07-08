import 'dart:async';

import 'package:ever_wallet/application/main/browser/requests/models/unsubscribe_input.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> unsubscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required GenericContractsRepository genericContractsRepository,
}) async {
  try {
    logger.d('unsubscribe', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = UnsubscribeInput.fromJson(jsonInput);

    if (!validateAddress(input.address)) throw Exception('Invalid address');

    genericContractsRepository.unsubscribe(input.address);

    final jsonOutput = <String, dynamic>{};

    return jsonOutput;
  } catch (err, st) {
    logger.e('unsubscribe', err, st);
    rethrow;
  }
}
