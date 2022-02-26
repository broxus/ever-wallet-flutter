import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/accounts_repository.dart';

final accountsProvider = StreamProvider<List<AssetsList>>(
  (ref) => getIt
      .get<AccountsRepository>()
      .currentAccountsStream
      .map((e) => [...e]..sort((a, b) => a.name.compareTo(b.name)))
      .doOnError((err, st) => logger.e(err, err, st)),
);
