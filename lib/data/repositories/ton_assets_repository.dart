import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/token_contract_asset.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class TonAssetsRepository {
  final _lock = Lock();
  final AccountsStorage _accountsStorage;
  final TransportSource _transportSource;
  final HiveSource _hiveSource;
  final HttpSource _httpSource;
  late final StreamSubscription _systemAssetsStreamSubscription;

  TonAssetsRepository({
    required AccountsStorage accountsStorage,
    required TransportSource transportSource,
    required HiveSource hiveSource,
    required HttpSource httpSource,
  })  : _accountsStorage = accountsStorage,
        _transportSource = transportSource,
        _hiveSource = hiveSource,
        _httpSource = httpSource {
    _systemAssetsStreamSubscription = Rx.combineLatest2<List<TokenContractAsset>,
            List<TokenContractAsset>, Tuple2<List<TokenContractAsset>, List<TokenContractAsset>>>(
      systemAssetsStream,
      customAssetsStream,
      (a, b) => Tuple2(a, b),
    )
        .distinct((a, b) => listEquals(a.item1, b.item1) && listEquals(a.item2, b.item2))
        .listen((e) => _lock.synchronized(() => _systemAssetsStreamListener(e)));

    _updateSystemTokenContractAssets().onError((err, st) => logger.e(err, err, st));
  }

  Stream<List<TokenContractAsset>> get systemAssetsStream =>
      _hiveSource.systemTokenContractAssetsStream;

  List<TokenContractAsset> get systemAssets => _hiveSource.systemTokenContractAssets;

  Stream<List<TokenContractAsset>> get customAssetsStream =>
      _hiveSource.customTokenContractAssetsStream;

  List<TokenContractAsset> get customAssets => _hiveSource.customTokenContractAssets;

  Stream<Tuple2<List<TokenContractAsset>, List<TokenContractAsset>>> accountAssetsOptions(
    String address,
  ) {
    final tokenWalletAssetsStream =
        Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
      _accountsStorage.entriesStream.expand((e) => e).where((e) => e.address == address),
      _transportSource.transportStream,
      (a, b) => Tuple2(a, b),
    ).map(
      (event) => event.item1.additionalAssets.entries
          .where((e) => e.key == event.item2.group)
          .map((e) => e.value.tokenWallets)
          .expand((e) => e)
          .toList(),
    );

    final tokenContractAssetsStream = Rx.combineLatest2<List<TokenContractAsset>,
        List<TokenContractAsset>, List<TokenContractAsset>>(
      systemAssetsStream,
      customAssetsStream,
      (a, b) => [
        ...a,
        ...b.where((e) => !a.contains(e)),
      ],
    );

    return Rx.combineLatest2<List<TokenWalletAsset>, List<TokenContractAsset>,
        Tuple2<List<TokenWalletAsset>, List<TokenContractAsset>>>(
      tokenWalletAssetsStream,
      tokenContractAssetsStream,
      (a, b) => Tuple2(a, b),
    ).map((event) {
      final added = event.item2
          .where((e) => event.item1.any((el) => el.rootTokenContract == e.address))
          .toList();
      final available = event.item2
          .where((e) => event.item1.every((el) => el.rootTokenContract != e.address))
          .toList();

      return Tuple2(
        added,
        available,
      );
    }).doOnError((err, st) => logger.e(err, err, st));
  }

  Stream<Tuple2<TonWalletAsset, List<TokenContractAsset>>> accountAssets(String address) {
    final tokenContractAssetsStream = Rx.combineLatest2<List<TokenContractAsset>,
        List<TokenContractAsset>, List<TokenContractAsset>>(
      systemAssetsStream,
      customAssetsStream,
      (a, b) => [
        ...a,
        ...b.where((e) => !a.contains(e)),
      ],
    );

    return Rx.combineLatest3<List<TokenContractAsset>, AssetsList, Transport,
        Tuple2<AssetsList, Transport>>(
      tokenContractAssetsStream,
      _accountsStorage.entriesStream.expand((e) => e).where((e) => e.address == address),
      _transportSource.transportStream,
      (a, b, c) => Tuple2(b, c),
    ).asyncMap((event) async {
      final tonWalletAsset = event.item1.tonWallet;
      final tokenWalletAssets = await event.item1.additionalAssets.entries
          .where((e) => e.key == event.item2.group)
          .map((e) => e.value.tokenWallets)
          .expand((e) => e)
          .asyncMap((e) => getTokenContractAsset(e.rootTokenContract))
          .then((v) => v.toList());

      return Tuple2(
        tonWalletAsset,
        tokenWalletAssets,
      );
    }).doOnError((err, st) => logger.e(err, err, st));
  }

  Future<TokenContractAsset> getTokenContractAsset(String rootTokenContract) async {
    var asset = systemAssets.firstWhereOrNull((e) => e.address == rootTokenContract) ??
        customAssets.firstWhereOrNull((e) => e.address == rootTokenContract);

    if (asset != null) return asset;

    final transport = _transportSource.transport;

    final tokenRootDetails = await getTokenRootDetails(
      transport: transport,
      rootTokenContract: rootTokenContract,
    );

    asset = TokenContractAsset(
      name: tokenRootDetails.name,
      symbol: tokenRootDetails.symbol,
      decimals: tokenRootDetails.decimals,
      address: rootTokenContract,
      version: tokenRootDetails.version.toInt(),
    );

    await _hiveSource.addCustomTokenContractAsset(asset);

    return asset;
  }

  Future<void> clear() async => _hiveSource.clearCustomTokenContractAssets();

  Future<void> dispose() => _systemAssetsStreamSubscription.cancel();

  Future<void> _updateSystemTokenContractAssets() async {
    final manifest = await _httpSource.getTonAssetsManifest();

    await _hiveSource.updateSystemTokenContractAssets(manifest.tokens);
  }

  Future<void> _systemAssetsStreamListener(
    Tuple2<List<TokenContractAsset>, List<TokenContractAsset>> event,
  ) async {
    try {
      final systemAssets = event.item1;
      final customAssets = event.item2;

      final duplicatedAssets =
          customAssets.where((e) => systemAssets.any((el) => e.address == el.address));

      for (final asset in duplicatedAssets) {
        _hiveSource.removeCustomTokenContractAsset(asset.address);
      }

      final oldAssets = customAssets
          .where((e) => e.version.toTokenWalletVersion() == TokenWalletVersion.oldTip3v4);

      for (final asset in oldAssets) {
        _hiveSource.removeCustomTokenContractAsset(asset.address);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
