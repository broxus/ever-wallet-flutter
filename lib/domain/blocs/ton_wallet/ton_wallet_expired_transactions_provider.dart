import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletExpiredTransactionsProvider = StreamProvider.family<List<PendingTransaction>, String>(
  (ref, address) => getIt
      .get<NekotonService>()
      .tonWalletsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .flatMap((e) => e.onMessageExpiredStream),
);
