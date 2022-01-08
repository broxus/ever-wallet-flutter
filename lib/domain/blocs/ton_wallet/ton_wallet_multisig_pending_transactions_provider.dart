import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletMultisigPendingTransactionsProvider = StreamProvider.family<List<MultisigPendingTransaction>, String>(
  (ref, address) => getIt
      .get<NekotonService>()
      .tonWalletsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .flatMap((e) => e.onStateChangedStream.asyncMap((_) => e.unconfirmedTransactions))
      .startWith([]),
);
