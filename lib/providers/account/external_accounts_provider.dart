import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../injection.dart';
import '../../../data/repositories/current_key_repository.dart';
import '../../../data/repositories/external_accounts_repository.dart';
import '../../../logger.dart';

final externalAccountsProvider = StreamProvider<List<String>>(
  (ref) => Rx.combineLatest2<KeyStoreEntry?, Map<String, List<String>>, List<String>>(
    getIt.get<CurrentKeyRepository>().currentKeyStream,
    getIt.get<ExternalAccountsRepository>().externalAccountsStream,
    (a, b) => b[a?.publicKey] ?? [],
  ).doOnError((err, st) => logger.e(err, err, st)),
);
