import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/generic_contracts_repository.dart';

final genericContractsStateChangesProvider = StreamProvider.autoDispose<ContractStateChangedEvent>(
  (ref) => getIt
      .get<GenericContractsRepository>()
      .stateChangesStream
      .map(
        (e) => ContractStateChangedEvent(
          address: e.item1,
          state: e.item2,
        ),
      )
      .doOnError((err, st) => logger.e(err, err, st)),
);
