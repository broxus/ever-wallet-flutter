import 'package:injectable/injectable.dart';

import '../models/token_wallet_info.dart';
import '../sources/local/hive_source.dart';

@lazySingleton
class TokenWalletInfoRepository {
  final HiveSource _hiveSource;

  TokenWalletInfoRepository(
    this._hiveSource,
  );

  TokenWalletInfo? get({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.getTokenWalletInfo(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  Future<void> save(TokenWalletInfo tokenWalletInfo) => _hiveSource.saveTokenWalletInfo(tokenWalletInfo);

  Future<void> remove({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.removeTokenWalletInfo(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  Future<void> clear() => _hiveSource.clearTokenWalletInfos();
}
