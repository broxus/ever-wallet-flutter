import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

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
  final _systemAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
  final _customAssetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);
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

  Stream<List<TokenContractAsset>> get systemAssetsStream => _systemAssetsSubject.stream;

  List<TokenContractAsset> get systemAssets => _systemAssetsSubject.value;

  Stream<List<TokenContractAsset>> get customAssetsStream => _customAssetsSubject.stream;

  List<TokenContractAsset> get customAssets => _customAssetsSubject.value;

  Future<TokenContractAsset> getTokenContractAsset(String rootTokenContract) async {
    var asset = systemAssets.firstWhereOrNull((e) => e.address == rootTokenContract) ??
        customAssets.firstWhereOrNull((e) => e.address == rootTokenContract);

    if (asset != null) return asset;

    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

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

  Future<void> _updateSystemTokenContractAssets() async {
    final manifest = await _restSource.getTonAssetsManifest();

    await _hiveSource.updateSystemTokenContractAssets(manifest.tokens);

    _customAssetsSubject.add(_hiveSource.customTokenContractAssets);
  }

  Future<void> _initialize() async {
    _systemAssetsSubject.add(_hiveSource.systemTokenContractAssets);
    _customAssetsSubject.add(_hiveSource.customTokenContractAssets);

    _updateSystemTokenContractAssets().onError((err, st) => logger.e(err, err, st));

    systemAssetsStream.listen((event) => _lock.synchronized(() => _systemAssetsStreamListener(event)));
  }

  Future<void> _systemAssetsStreamListener(List<TokenContractAsset> event) async {
    try {
      final duplicatedAssets = customAssets.where((e) => event.any((el) => e.address == el.address));

      for (final asset in duplicatedAssets) {
        _hiveSource.removeCustomTokenContractAsset(asset.address);

        _customAssetsSubject.add(_hiveSource.customTokenContractAssets);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
