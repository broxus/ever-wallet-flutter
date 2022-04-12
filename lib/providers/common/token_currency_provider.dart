import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../data/models/currency.dart';
import '../../data/repositories/token_currencies_repository.dart';
import '../../logger.dart';

final tokenCurrencyProvider = StreamProvider.autoDispose.family<Currency?, String>(
  (ref, currency) => getIt
      .get<TokenCurrenciesRepository>()
      .currenciesStream
      .expand((e) => e)
      .where((e) => e.currency == currency)
      .doOnError((err, st) => logger.e(err, err, st)),
);
