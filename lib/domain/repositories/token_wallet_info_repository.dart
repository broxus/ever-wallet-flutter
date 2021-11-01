import 'package:crystal/domain/models/token_wallet_info.dart';

abstract class TokenWalletInfoRepository {
  TokenWalletInfo? get({
    required String owner,
    required String rootTokenContract,
  });

  Future<void> save(TokenWalletInfo tokenWalletInfo);

  Future<void> remove({
    required String owner,
    required String rootTokenContract,
  });

  Future<void> clear();
}
