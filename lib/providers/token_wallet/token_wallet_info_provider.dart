import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/models/token_wallet_info.dart';
import '../../../injection.dart';
import '../../data/repositories/token_wallets_repository.dart';
import '../../logger.dart';

final tokenWalletInfoProvider = StreamProvider.family<TokenWalletInfo?, Tuple2<String, String>>(
  (ref, params) => getIt
      .get<TokenWalletsRepository>()
      .getInfoStream(owner: params.item1, rootTokenContract: params.item2)
      .doOnError((err, st) => logger.e(err, err, st)),
);
