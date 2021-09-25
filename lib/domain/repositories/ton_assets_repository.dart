import '../models/token_contract_asset.dart';

abstract class TonAssetsRepository {
  Stream<List<TokenContractAsset>> getTokenContractAssetsStream({bool refresh = false});

  Future<String?> getTokenLogoUri(String address);

  Future<void> clear();
}
