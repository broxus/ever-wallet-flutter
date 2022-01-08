import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/repositories/token_wallet_info_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tokenWalletInfoProvider = StreamProvider.family<TokenWalletInfo?, Tuple2<String, String>>((ref, params) {
  final owner = params.item1;
  final rootTokenContract = params.item2;

  final stream = getIt
      .get<NekotonService>()
      .tokenWalletsStream
      .expand((e) => e)
      .where((e) => e.owner == params.item1 && e.symbol.rootTokenContract == params.item2);

  final cached = getIt.get<TokenWalletInfoRepository>().get(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  return Rx.combineLatest2<TokenWallet, String?, TokenWallet>(
    stream,
    stream.flatMap((e) => e.onBalanceChangedStream).cast<String?>().startWith(null),
    (a, b) => a,
  )
      .asyncMap(
        (e) async {
          final tokenWalletInfo = TokenWalletInfo(
            owner: e.owner,
            address: e.address,
            symbol: e.symbol,
            version: e.version,
            balance: await e.balance,
            contractState: await e.contractState,
          );

          await getIt.get<TokenWalletInfoRepository>().save(tokenWalletInfo);

          return tokenWalletInfo;
        },
      )
      .cast<TokenWalletInfo?>()
      .startWith(cached);
});
