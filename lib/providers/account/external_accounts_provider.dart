import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/keys_repository.dart';

final externalAccountsProvider = StreamProvider.autoDispose<List<String>>(
  (ref) => Rx.combineLatest2<KeyStoreEntry?, Map<String, List<String>>, List<String>>(
    getIt.get<KeysRepository>().currentKeyStream,
    getIt.get<AccountsRepository>().externalAccountsStream,
    (a, b) => b[a?.publicKey] ?? [],
  ).doOnError((err, st) => logger.e(err, err, st)),
);
