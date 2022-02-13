import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:tuple/tuple.dart';

import '../extensions.dart';
import '../models/token_contract_asset.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';
import 'accounts_storage_repository.dart';
import 'transport_repository.dart';

@preResolve
@lazySingleton
class TonAssetsRepository {
  final HiveSource _hiveSource;
  final RestSource _restSource;
  final TransportRepository _transportRepository;
  final AccountsStorageRepository _accountsStorageRepository;
  final _assetsSubject = BehaviorSubject<List<TokenContractAsset>>.seeded([]);

  TonAssetsRepository._(
    this._hiveSource,
    this._restSource,
    this._transportRepository,
    this._accountsStorageRepository,
  );

  @factoryMethod
  static Future<TonAssetsRepository> create({
    required HiveSource hiveSource,
    required RestSource restSource,
    required TransportRepository transportRepository,
    required AccountsStorageRepository accountsStorageRepository,
  }) async {
    final tonAssetsRepositoryImpl = TonAssetsRepository._(
      hiveSource,
      restSource,
      transportRepository,
      accountsStorageRepository,
    );
    await tonAssetsRepositoryImpl._initialize();
    return tonAssetsRepositoryImpl;
  }

  Stream<List<TokenContractAsset>> get assetsStream => _assetsSubject.stream;

  List<TokenContractAsset> get assets => _assetsSubject.value;

  Future<void> save(TokenContractAsset asset) async {
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
      final asset = TokenContractAsset(
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
    final tokenWallet = await TokenWallet.subscribe(
      transport: _transportRepository.transport,
      owner: address,
      rootTokenContract: rootTokenContract,
    );

    final asset = TokenContractAsset(
      name: tokenWallet.symbol.fullName,
      symbol: tokenWallet.symbol.name,
      decimals: tokenWallet.symbol.decimals,
      address: tokenWallet.symbol.rootTokenContract,
      version: tokenWallet.version.toManifest(),
    );

    await tokenWallet.freePtr();

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

    _accountsStorageRepository.accountsStream
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
