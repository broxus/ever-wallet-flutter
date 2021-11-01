import '../models/token_contract_asset.dart';

abstract class TonAssetsRepository {
  Stream<List<TokenContractAsset>> get assetsStream;

  List<TokenContractAsset> get assets;

  Future<void> save(TokenContractAsset asset);

  Future<void> saveCustom({
    required String name,
    required String symbol,
    required int decimals,
    required String address,
    required int version,
  });

  Future<void> remove(String address);

  Future<void> clear();
}
