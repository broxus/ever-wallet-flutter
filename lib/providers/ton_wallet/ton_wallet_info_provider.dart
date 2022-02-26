import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/models/ton_wallet_info.dart';
import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/ton_wallets_repository.dart';

final tonWalletInfoProvider = StreamProvider.family<TonWalletInfo?, String>(
  (ref, address) =>
      getIt.get<TonWalletsRepository>().getInfoStream(address).doOnError((err, st) => logger.e(err, err, st)),
);
