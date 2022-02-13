import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/accounts_storage_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final accountInfoProvider = StreamProvider.family<AssetsList, String>(
  (ref, address) => getIt
      .get<AccountsStorageRepository>()
      .accountsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .doOnError((err, st) => logger.e(err, err, st)),
);
