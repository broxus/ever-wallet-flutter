import 'package:collection/collection.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:rxdart/rxdart.dart';

Stream<Currency> tokenCurrencyStream(
        TokenCurrenciesRepository tokenCurrenciesRepository,
        TransportRepository transportRepository,
        [String? rootTokenContract]) =>
    Rx.combineLatest2(
      tokenCurrenciesRepository.currenciesStream,
      transportRepository.networkTypeStream,
      (a, networkType) {
        final address = rootTokenContract ??
            transportRepository.networkType.when(
              everscale: () => kAddressForEverCurrency,
              venom: () => kAddressForVenomCurrency,
              tycho: () => kAddressForTychoCurrency,
            );
        return a[networkType]?.firstWhereOrNull((e) => e.address == address);
      },
    ).whereNotNull().doOnError((err, st) => logger.e(err, err, st));
