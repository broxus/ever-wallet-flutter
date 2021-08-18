import 'package:injectable/injectable.dart';

import '../../domain/models/token_contract_asset.dart';
import '../../domain/repositories/ton_assets_repository.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';

@LazySingleton(as: TonAssetsRepository)
class TonAssetsRepositoryImpl implements TonAssetsRepository {
  final HiveSource _hiveSource;
  final RestSource _restSource;

  TonAssetsRepositoryImpl(
    this._hiveSource,
    this._restSource,
  );

  @override
  Stream<List<TokenContractAsset>> getTokenContractAssetsStream({bool refresh = false}) async* {
    final cached = await _hiveSource.getTokenContractAssets();

    if (cached.isNotEmpty) {
      final assets = cached.map((e) => e.toDomain()).toList();
      yield assets;
    }

    if (cached.isEmpty || refresh) {
      final assets = await _restSource.getTokenContractAssets();
      _hiveSource.cacheTokenContractAssets(assets);
      yield assets.map((e) => e.toDomain()).toList();
    }
  }

  @override
  Future<void> clear() async => _hiveSource.clearTokenContractAssets();
}
