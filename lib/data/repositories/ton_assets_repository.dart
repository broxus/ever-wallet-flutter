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
  final _systemAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  final _customAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  late final StreamSubscription _systemAssetsStreamSubscription;

  TonAssetsRepository(
    this._accountsStorage,
    this._transportSource,
    this._hiveSource,
    this._httpSource,
  ) {
    _systemAssetsStreamSubscription = Rx.combineLatest2<List<TokenContractAsset>,
            List<TokenContractAsset>, Tuple2<List<TokenContractAsset>, List<TokenContractAsset>>>(
      systemAssetsStream,
      customAssetsStream,
      (a, b) => Tuple2(a, b),
    )
        .distinct((a, b) => listEquals(a.item1, b.item1) && listEquals(a.item2, b.item2))
        .listen((event) => _lock.synchronized(() => _systemAssetsStreamListener(event)));

    _systemAssetsSubject.add(_hiveSource.systemTokenContractAssets);
    _customAssetsSubject.add(_hiveSource.customTokenContractAssets);

    _updateSystemTokenContractAssets().onError((err, st) => logger.e(err, err, st));
  }

  Stream<List<TokenContractAsset>> get systemAssetsStream =>
      _systemAssetsSubject.distinct((a, b) => listEquals(a, b));

  List<TokenContractAsset> get systemAssets => _systemAssetsSubject.value;

  Stream<List<TokenContractAsset>> get customAssetsStream =>
      _customAssetsSubject.distinct((a, b) => listEquals(a, b));

  List<TokenContractAsset> get customAssets => _customAssetsSubject.value;

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

    final transport = await _transportSource.transport;

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

    _customAssetsSubject.add(_hiveSource.customTokenContractAssets);

    return asset;
  }

  Future<void> clear() async => _hiveSource.clearCustomTokenContractAssets();

  Future<void> dispose() async {
    await _systemAssetsStreamSubscription.cancel();

    await _customAssetsSubject.close();
    await _systemAssetsSubject.close();
  }

  Future<void> _updateSystemTokenContractAssets() async {
    final manifest = await _httpSource.getTonAssetsManifest();

    await _hiveSource.updateSystemTokenContractAssets(manifest.tokens);

    _systemAssetsSubject.add(_hiveSource.systemTokenContractAssets);
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

        _customAssetsSubject.add(_hiveSource.customTokenContractAssets);
      }

      final oldAssets = customAssets
          .where((e) => e.version.toTokenWalletVersion() == TokenWalletVersion.oldTip3v4);

      for (final asset in oldAssets) {
        _hiveSource.removeCustomTokenContractAsset(asset.address);

        _customAssetsSubject.add(_hiveSource.customTokenContractAssets);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
