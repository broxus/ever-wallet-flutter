import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../extensions.dart';
import '../models/token_contract_asset.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';
import '../sources/remote/transport_source.dart';

@preResolve
@lazySingleton
class TonAssetsRepository {
  final TransportSource _transportSource;
  final HiveSource _hiveSource;
  final RestSource _restSource;
  final _everSystemAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  final _everCustomAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  final _venomSystemAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  final _venomCustomAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  final _lock = Lock();

  TonAssetsRepository._(
    this._transportSource,
    this._hiveSource,
    this._restSource,
  );

  @factoryMethod
  static Future<TonAssetsRepository> create({
    required TransportSource transportSource,
    required HiveSource hiveSource,
    required RestSource restSource,
  }) async {
    final instance = TonAssetsRepository._(
      transportSource,
      hiveSource,
      restSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<List<TokenContractAsset>> get systemAssetsStream => _transportSource.transportStream
      .flatMap(
        (v) => !v.connectionData.name.contains('Venom')
            ? _everSystemAssetsSubject
            : _venomSystemAssetsSubject,
      )
      .distinct((a, b) => listEquals(a, b));

  Future<List<TokenContractAsset>> get systemAssets async {
    final isEver = !(await _transportSource.transport).connectionData.name.contains('Venom');

    return isEver ? _venomSystemAssetsSubject.value : _everSystemAssetsSubject.value;
  }

  Stream<List<TokenContractAsset>> get customAssetsStream => _transportSource.transportStream
      .flatMap(
        (v) => !v.connectionData.name.contains('Venom')
            ? _everSystemAssetsSubject
            : _venomSystemAssetsSubject,
      )
      .distinct((a, b) => listEquals(a, b));

  Future<List<TokenContractAsset>> get customAssets async {
    final isEver = !(await _transportSource.transport).connectionData.name.contains('Venom');

    return isEver ? _venomCustomAssetsSubject.value : _everCustomAssetsSubject.value;
  }

  Future<TokenContractAsset> getTokenContractAsset(String rootTokenContract) async {
    var asset = (_venomSystemAssetsSubject.value)
            .firstWhereOrNull((e) => e.address == rootTokenContract) ??
        (_everSystemAssetsSubject.value).firstWhereOrNull((e) => e.address == rootTokenContract) ??
        (_venomCustomAssetsSubject.value).firstWhereOrNull((e) => e.address == rootTokenContract) ??
        (_everCustomAssetsSubject.value).firstWhereOrNull((e) => e.address == rootTokenContract);

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

    final isEver = !(await _transportSource.transport).connectionData.name.contains('Venom');

    if (isEver) {
      await _hiveSource.addEverCustomTokenContractAsset(asset);

      _everCustomAssetsSubject.add(_hiveSource.everCustomTokenContractAssets);
    } else {
      await _hiveSource.addVenomCustomTokenContractAsset(asset);

      _venomCustomAssetsSubject.add(_hiveSource.venomCustomTokenContractAssets);
    }

    return asset;
  }

  Future<void> clear() async {
    await _hiveSource.clearEverCustomTokenContractAssets();
    await _hiveSource.clearVenomCustomTokenContractAssets();
  }

  Future<void> _updateEverSystemTokenContractAssets() async {
    final manifest = await _restSource.getEverTonAssetsManifest();

    await _hiveSource.updateEverSystemTokenContractAssets(manifest.tokens);

    _everSystemAssetsSubject.add(_hiveSource.everSystemTokenContractAssets);
  }

  Future<void> _updateVenomSystemTokenContractAssets() async {
    final manifest = await _restSource.getVenomTonAssetsManifest();

    await _hiveSource.updateVenomSystemTokenContractAssets(manifest.tokens);

    _venomSystemAssetsSubject.add(_hiveSource.venomSystemTokenContractAssets);
  }

  Future<void> _initialize() async {
    Rx.combineLatest2<List<TokenContractAsset>, List<TokenContractAsset>,
            Tuple2<List<TokenContractAsset>, List<TokenContractAsset>>>(
      systemAssetsStream,
      customAssetsStream,
      (a, b) => Tuple2(a, b),
    )
        .distinct((a, b) => listEquals(a.item1, b.item1) && listEquals(a.item2, b.item2))
        .listen((event) => _lock.synchronized(() => _systemAssetsStreamListener(event)));

    _everSystemAssetsSubject.add(_hiveSource.everSystemTokenContractAssets);
    _everCustomAssetsSubject.add(_hiveSource.everCustomTokenContractAssets);

    _venomSystemAssetsSubject.add(_hiveSource.venomSystemTokenContractAssets);
    _venomCustomAssetsSubject.add(_hiveSource.venomCustomTokenContractAssets);

    _updateEverSystemTokenContractAssets().onError((err, st) => logger.e(err, err, st));
    _updateVenomSystemTokenContractAssets().onError((err, st) => logger.e(err, err, st));
  }

  Future<void> _systemAssetsStreamListener(
    Tuple2<List<TokenContractAsset>, List<TokenContractAsset>> event,
  ) async {
    try {
      final isEver = !(await _transportSource.transport).connectionData.name.contains('Venom');

      final systemAssets = event.item1;
      final customAssets = event.item2;

      final duplicatedAssets =
          customAssets.where((e) => systemAssets.any((el) => e.address == el.address));

      for (final asset in duplicatedAssets) {
        if (isEver) {
          _hiveSource.removeEverCustomTokenContractAsset(asset.address);

          _everCustomAssetsSubject.add(_hiveSource.everCustomTokenContractAssets);
        } else {
          _hiveSource.removeVenomCustomTokenContractAsset(asset.address);

          _venomCustomAssetsSubject.add(_hiveSource.venomCustomTokenContractAssets);
        }
      }

      final oldAssets = customAssets
          .where((e) => e.version.toTokenWalletVersion() == TokenWalletVersion.oldTip3v4);

      for (final asset in oldAssets) {
        if (isEver) {
          _hiveSource.removeEverCustomTokenContractAsset(asset.address);

          _everCustomAssetsSubject.add(_hiveSource.everCustomTokenContractAssets);
        } else {
          _hiveSource.removeVenomCustomTokenContractAsset(asset.address);

          _venomCustomAssetsSubject.add(_hiveSource.venomCustomTokenContractAssets);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
