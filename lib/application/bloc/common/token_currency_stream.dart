import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';

Stream<Currency> tokenCurrencyStream(
  TokenCurrenciesRepository tokenCurrenciesRepository,
  String rootTokenContract,
) =>
    tokenCurrenciesRepository.currenciesStream
        .expand((e) => e)
        .where((e) => e.address == rootTokenContract);
