import 'package:crystal/data/dtos/token_wallet_info_dto.dart';
import 'package:crystal/domain/models/token_wallet_info.dart';
import 'package:crystal/domain/repositories/token_wallet_info_repository.dart';
import 'package:injectable/injectable.dart';

import '../sources/local/hive_source.dart';

@LazySingleton(as: TokenWalletInfoRepository)
class TokenWalletInfoRepositoryImpl implements TokenWalletInfoRepository {
  final HiveSource _hiveSource;

  TokenWalletInfoRepositoryImpl(this._hiveSource);

  @override
  TokenWalletInfo? get({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource
          .getTokenWalletInfo(
            owner: owner,
            rootTokenContract: rootTokenContract,
          )
          ?.toModel();

  @override
  Future<void> save(TokenWalletInfo tokenWalletInfo) => _hiveSource.saveTokenWalletInfo(tokenWalletInfo.toDto());

  @override
  Future<void> remove({
    required String owner,
    required String rootTokenContract,
  }) =>
      _hiveSource.removeTokenWalletInfo(
        owner: owner,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<void> clear() => _hiveSource.clearTokenWalletInfos();
}
