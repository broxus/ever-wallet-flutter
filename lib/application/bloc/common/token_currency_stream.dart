import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

Stream<Currency> tokenCurrencyStream(
  TokenCurrenciesRepository tokenCurrenciesRepository,
  TransportRepository transportRepository,
  String rootTokenContract,
) =>
    Rx.combineLatest2<Map<String, List<Currency>>, Transport, List<Currency>>(
      tokenCurrenciesRepository.currenciesStream,
      transportRepository.transportStream,
      (a, b) {
        final isEver = !b.name.contains('Venom');
        return a[isEver ? kEverNetworkName : kVenomNetworkName] ?? [];
      },
    )
        .expand((e) => e)
        .where((e) => e.address == rootTokenContract)
        .doOnError((err, st) => logger.e(err, err, st));
