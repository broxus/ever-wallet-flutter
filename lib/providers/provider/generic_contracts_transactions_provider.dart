import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/generic_contracts_repository.dart';
import '../../presentation/main/browser/events/models/transactions_found_event.dart';

final genericContractsTransactionsProvider = StreamProvider.autoDispose<TransactionsFoundEvent>(
  (ref) => getIt
      .get<GenericContractsRepository>()
      .transactionsStream
      .map(
        (e) => TransactionsFoundEvent(
          address: e.item1,
          transactions: e.item2,
          info: e.item3,
        ),
      )
      .doOnError((err, st) => logger.e(err, err, st)),
);
