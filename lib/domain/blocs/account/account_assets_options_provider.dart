import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/dtos/token_contract_asset_dto.dart';
import '../../../data/repositories/ton_assets_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final accountAssetsOptionsProvider =
    StreamProvider.family<Tuple2<List<TokenContractAssetDto>, List<TokenContractAssetDto>>, String>(
  (ref, address) => Rx.combineLatest2<List<TokenWalletAsset>, List<TokenContractAssetDto>,
      Tuple2<List<TokenWalletAsset>, List<TokenContractAssetDto>>>(
    Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
      getIt.get<NekotonService>().accountsStream.expand((e) => e).where((e) => e.address == address),
      getIt.get<NekotonService>().transportStream,
      (a, b) => Tuple2(a, b),
    ).map(
      (event) => event.item1.additionalAssets.entries
          .where((e) => e.key == event.item2.connectionData.group)
          .map((e) => e.value.tokenWallets)
          .expand((e) => e)
          .toList(),
    ),
    getIt.get<TonAssetsRepository>().assetsStream,
    (a, b) => Tuple2(a, b),
  ).map((event) {
    final added = event.item2.where((e) => event.item1.any((el) => el.rootTokenContract == e.address)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final available = event.item2.where((e) => event.item1.every((el) => el.rootTokenContract != e.address)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Tuple2(
      added,
      available,
    );
  }),
);
