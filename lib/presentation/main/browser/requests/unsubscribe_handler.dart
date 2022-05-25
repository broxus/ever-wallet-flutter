import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../injection.dart';
import 'models/unsubscribe_input.dart';

Future<Map<String, dynamic>> unsubscribeHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('unsubscribe', args);

    final jsonInput = args.first as Map<String, dynamic>;
    final input = UnsubscribeInput.fromJson(jsonInput);

    if (!validateAddress(input.address)) throw Exception('Invalid address');

    getIt.get<GenericContractsRepository>().unsubscribe(input.address);

    final jsonOutput = <String, dynamic>{};

    return jsonOutput;
  } catch (err, st) {
    logger.e('unsubscribe', err, st);
    rethrow;
  }
}
