import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final accountCreationOptionsProvider = StreamProvider.family<Tuple2<List<WalletType>, List<WalletType>>, String>(
  (ref, publicKey) => getIt
      .get<NekotonService>()
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
  }),
);
