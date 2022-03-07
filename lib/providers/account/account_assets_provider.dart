import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/models/token_contract_asset.dart';
import '../../../data/repositories/ton_assets_repository.dart';
import '../../../data/repositories/transport_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/extensions.dart';
import '../../data/repositories/accounts_repository.dart';

final accountAssetsProvider = StreamProvider.family<Tuple2<TonWalletAsset, List<TokenContractAsset>>, String>(
  (ref, address) {
    final tokenContractAssetsStream =
        Rx.combineLatest2<List<TokenContractAsset>, List<TokenContractAsset>, List<TokenContractAsset>>(
      getIt.get<TonAssetsRepository>().systemAssetsStream,
      getIt.get<TonAssetsRepository>().customAssetsStream,
      (a, b) => [
        ...a,
        ...b.where((e) => !a.contains(e)),
      ],
    );

    return Rx.combineLatest3<List<TokenContractAsset>, AssetsList, Transport, Tuple2<AssetsList, Transport>>(
      tokenContractAssetsStream,
      getIt.get<AccountsRepository>().accountsStream.expand((e) => e).where((e) => e.address == address),
      getIt.get<TransportRepository>().transportStream.whereType<Transport>(),
      (a, b, c) => Tuple2(b, c),
    ).asyncMap((event) async {
      final tonWalletAsset = event.item1.tonWallet;
      final tokenWalletAssets = await event.item1.additionalAssets.entries
          .where((e) => e.key == event.item2.connectionData.group)
          .map((e) => e.value.tokenWallets)
          .expand((e) => e)
          .asyncMap((e) => getIt.get<TonAssetsRepository>().getTokenContractAsset(e.rootTokenContract))
          .then((v) => v.toList());

      return Tuple2(
        tonWalletAsset,
        tokenWalletAssets,
      );
    }).doOnError((err, st) => logger.e(err, err, st));
  },
);
