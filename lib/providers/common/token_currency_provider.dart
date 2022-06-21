import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../data/models/currency.dart';
import '../../data/repositories/token_currencies_repository.dart';
import '../../logger.dart';

final tokenCurrencyProvider = StreamProvider.autoDispose.family<Currency?, String>(
  (ref, rootTokenContract) => getIt
      .get<TokenCurrenciesRepository>()
      .currenciesStream
      .expand((e) => e)
      .where((e) => e.address == rootTokenContract)
      .doOnError((err, st) => logger.e(err, err, st)),
);
