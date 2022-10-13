import 'dart:async';

import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<Map<String, dynamic>> unsubscribeAllHandler({
  required InAppWebViewController controller,
  required int tabId,
  required List<dynamic> args,
  required GenericContractsRepository genericContractsRepository,
}) async {
  try {
    logger.d('unsubscribeAll', args);

    await genericContractsRepository.unsubscribeTab(tabId);

    final jsonOutput = <String, dynamic>{};

    return jsonOutput;
  } catch (err, st) {
    logger.e('unsubscribeAll', err, st);
    rethrow;
  }
}
