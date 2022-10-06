import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/constants.dart';
import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/transport_repository.dart';

final accountCreationOptionsProvider =
    StreamProvider.autoDispose.family<Tuple2<List<WalletType>, List<WalletType>>, String>(
  (ref, publicKey) {
    final accountsStream = getIt
        .get<AccountsRepository>()
        .accountsStream
        .map((e) => e.where((e) => e.publicKey == publicKey))
        .map((e) => e.map((e) => e.tonWallet.contract));

    final transportStream = getIt.get<TransportRepository>().transportStream;

    return Rx.combineLatest2<Iterable<WalletType>, Transport,
        Tuple2<Iterable<WalletType>, Transport>>(
      accountsStream,
      transportStream,
      (a, b) => Tuple2(a, b),
    ).map((e) {
      final added = e.item1.toList();

      final isEver = !e.item2.connectionData.name.contains('Venom');

      final available = (isEver ? kEverAvailableWallets : kVenomAvailableWallets)
          .where((el) => !e.item1.contains(el))
          .toList();

      return Tuple2(
        added,
        available,
      );
    }).doOnError((err, st) => logger.e(err, err, st));
  },
);
