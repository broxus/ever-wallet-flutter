import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';
import 'package:tuple/tuple.dart';

import '../dtos/token_contract_asset_dto.dart';
import '../services/nekoton_service.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';

@preResolve
@lazySingleton
class TonAssetsRepository {
  final HiveSource _hiveSource;
  final RestSource _restSource;
  final NekotonService _nekotonService;
  final _assetsSubject = BehaviorSubject<List<TokenContractAssetDto>>.seeded([]);

  TonAssetsRepository._(
    this._hiveSource,
    this._restSource,
    this._nekotonService,
  );

  @factoryMethod
  static Future<TonAssetsRepository> create(
    HiveSource hiveSource,
    RestSource restSource,
    NekotonService nekotonService,
  ) async {
    final tonAssetsRepositoryImpl = TonAssetsRepository._(
      hiveSource,
      restSource,
      nekotonService,
    );
    await tonAssetsRepositoryImpl._initialize();
    return tonAssetsRepositoryImpl;
  }

  Stream<List<TokenContractAssetDto>> get assetsStream => _assetsSubject.stream;

  List<TokenContractAssetDto> get assets => _assetsSubject.value;

  Future<void> save(TokenContractAssetDto asset) async {
    await _hiveSource.saveTokenContractAsset(asset);

    _assetsSubject.add([
      ..._assetsSubject.value.where((e) => e.address != asset.address),
      asset,
    ]);
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

    for (final token in manifest.tokens) {
      final asset = TokenContractAssetDto(
        name: token.name,
        chainId: token.chainId,
        symbol: token.symbol,
        decimals: token.decimals,
        address: token.address,
        logoURI: token.logoURI,
        version: token.version,
      );

      await _hiveSource.saveTokenContractAsset(asset);

      _assetsSubject.add([
        ..._assetsSubject.value.where((e) => e.address != asset.address),
        asset,
      ]);
    }
  }

  Future<void> _saveCustom({
    required String address,
    required String rootTokenContract,
  }) async {
    final tokenWalletInfo = await _nekotonService.getTokenWalletInfo(
      address: address,
      rootTokenContract: rootTokenContract,
    );

    final asset = TokenContractAssetDto(
      name: tokenWalletInfo.symbol.fullName,
      symbol: tokenWalletInfo.symbol.name,
      decimals: tokenWalletInfo.symbol.decimals,
      address: tokenWalletInfo.symbol.rootTokenContract,
      version: tokenWalletInfo.version.index + 1,
    );

    await _hiveSource.saveTokenContractAsset(asset);

    _assetsSubject.add([
      ..._assetsSubject.value.where((e) => e.address != asset.address),
      asset,
    ]);
  }

  Future<void> _initialize() async {
    final cached = _hiveSource.getTokenContractAssets();

    _assetsSubject.add(cached);

    await refresh();

    _nekotonService.accountsStream
        .expand((e) => e)
        .map(
          (e) => e.additionalAssets.values
              .map((e) => e.tokenWallets)
              .expand((e) => e)
              .map((el) => Tuple2(e.address, el.rootTokenContract)),
        )
        .expand((e) => e)
        .listen((event) async {
      final contains = assets.any((e) => e.address == event.item2);

      if (!contains) {
        await _saveCustom(
          address: event.item1,
          rootTokenContract: event.item2,
        );
      }
    });
  }
}
