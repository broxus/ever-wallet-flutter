import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/constants.dart';
import '../../../data/repositories/accounts_storage_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final accountCreationOptionsProvider = StreamProvider.family<Tuple2<List<WalletType>, List<WalletType>>, String>(
  (ref, publicKey) => getIt
      .get<AccountsStorageRepository>()
      .accountsStream
      .map((e) => e.where((e) => e.publicKey == publicKey))
      .map((e) => e.map((e) => e.tonWallet.contract))
      .map((e) {
    final added = e.toList();
    final available = kAvailableWallets.where((el) => !e.contains(el)).toList();

    return Tuple2(
      added,
      available,
    );
  }).doOnError((err, st) => logger.e(err, err, st)),
);
