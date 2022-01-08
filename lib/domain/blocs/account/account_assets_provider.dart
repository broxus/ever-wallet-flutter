import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/dtos/token_contract_asset_dto.dart';
import '../../../data/repositories/ton_assets_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final accountAssetsProvider = StreamProvider.family<Tuple2<TonWalletAsset, List<TokenContractAssetDto>>, String>(
  (ref, address) => Rx.combineLatest2<Tuple2<TonWalletAsset, List<TokenWalletAsset>>, List<TokenContractAssetDto>,
      Tuple2<Tuple2<TonWalletAsset, List<TokenWalletAsset>>, List<TokenContractAssetDto>>>(
    Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
      getIt.get<NekotonService>().accountsStream.expand((e) => e).where((e) => e.address == address),
      getIt.get<NekotonService>().transportStream,
      (a, b) => Tuple2(a, b),
    ).map((event) {
      final tonWalletAsset = event.item1.tonWallet;
      final tokenWalletAssets = event.item1.additionalAssets.entries
          .where((e) => e.key == event.item2.connectionData.group)
          .map((e) => e.value.tokenWallets)
          .expand((e) => e)
          .toList();

      return Tuple2(
        tonWalletAsset,
        tokenWalletAssets,
      );
    }),
    getIt.get<TonAssetsRepository>().assetsStream,
    (a, b) => Tuple2(a, b),
  ).map((event) {
    final tonWalletAsset = event.item1.item1;
    final tokenContractAssets = event.item2
        .where((e) => event.item1.item2.any((el) => el.rootTokenContract == e.address))
        .toList()
      ..sort((a, b) => b.address.compareTo(a.address));

    return Tuple2(
      tonWalletAsset,
      tokenContractAssets,
    );
  }),
);
