import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../dtos/token_contract_asset_dto.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';

@preResolve
@lazySingleton
class TonAssetsRepository {
  final HiveSource _hiveSource;
  final RestSource _restSource;
  final _assetsSubject = BehaviorSubject<List<TokenContractAssetDto>>.seeded([]);

  TonAssetsRepository._(
    this._hiveSource,
    this._restSource,
  );

  @factoryMethod
  static Future<TonAssetsRepository> create(
    HiveSource hiveSource,
    RestSource restSource,
  ) async {
    final tonAssetsRepositoryImpl = TonAssetsRepository._(
      hiveSource,
      restSource,
    );
    await tonAssetsRepositoryImpl._initialize();
    return tonAssetsRepositoryImpl;
  }

  Stream<List<TokenContractAssetDto>> get assetsStream =>
      _assetsSubject.stream.distinct((previous, next) => listEquals(previous, next));

  List<TokenContractAssetDto> get assets => _assetsSubject.value;

  Future<void> save(TokenContractAssetDto asset) async {
    await _hiveSource.saveTokenContractAsset(asset);

    final assets = _assetsSubject.value.where((e) => e.address != asset.address).toList()..add(asset);
    _assetsSubject.add(assets);
  }

  Future<void> saveCustom({
    required String name,
    required String symbol,
    required int decimals,
    required String address,
    required int version,
  }) async {
    final asset = TokenContractAssetDto(
      name: name,
      symbol: symbol,
      decimals: decimals,
      address: address,
      version: version,
    );

    await _hiveSource.saveTokenContractAsset(asset);

    final assets = _assetsSubject.value.where((e) => e.address != asset.address).toList()..add(asset);
    _assetsSubject.add(assets);
  }

  Future<void> remove(String address) async {
    final assets = _assetsSubject.value.where((e) => e.address != address).toList();
    _assetsSubject.add(assets);

    await _hiveSource.removeTokenContractAsset(address);
  }

  Future<void> clear() async {
    _assetsSubject.add([]);

    await _hiveSource.clearTokenContractAssets();
  }

  Future<void> refresh() async {
    final manifest = await _restSource.getTonAssetsManifest();

    final assets = <TokenContractAssetDto>[];

    for (final token in manifest.tokens) {
      String? icon;

      final logoURI = token.logoURI;

      if (logoURI != null) {
        icon = await _restSource.getTokenSvgIcon(logoURI);
      }

      final asset = TokenContractAssetDto(
        name: token.name,
        chainId: token.chainId,
        symbol: token.symbol,
        decimals: token.decimals,
        address: token.address,
        icon: icon,
        version: token.version,
      );

      await _hiveSource.saveTokenContractAsset(asset);

      assets.add(asset);
    }

    final old = [..._assetsSubject.value]..removeWhere((e) => assets.any((el) => e.address == el.address));

    final list = [
      ...assets,
      ...old,
    ];

    _assetsSubject.add(list);
  }

  Future<void> _initialize() async {
    final assets = _hiveSource.getTokenContractAssets();

    if (assets.isEmpty) {
      await refresh();
    } else {
      _assetsSubject.add(assets);

      refresh();
    }
  }
}
