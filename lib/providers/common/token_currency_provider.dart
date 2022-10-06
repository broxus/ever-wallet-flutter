import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../data/models/currency.dart';
import '../../data/repositories/token_currencies_repository.dart';
import '../../data/repositories/transport_repository.dart';
import '../../logger.dart';

final tokenCurrencyProvider = StreamProvider.autoDispose.family<Currency?, String>(
  (ref, rootTokenContract) =>
      Rx.combineLatest2<Map<String, List<Currency>>, Transport, List<Currency>>(
    getIt.get<TokenCurrenciesRepository>().currenciesStream,
    getIt.get<TransportRepository>().transportStream,
    (a, b) {
      final isEver = !b.connectionData.name.contains('Venom');

      return a[isEver ? 'ever' : 'venom'] ?? [];
    },
  )
          .expand((e) => e)
          .where((e) => e.address == rootTokenContract)
          .doOnError((err, st) => logger.e(err, err, st)),
);
