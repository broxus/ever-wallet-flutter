import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/accounts_repository.dart';

final accountInfoProvider = StreamProvider.family<AssetsList, String>(
  (ref, address) => getIt
      .get<AccountsRepository>()
      .accountsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .doOnError((err, st) => logger.e(err, err, st)),
);
