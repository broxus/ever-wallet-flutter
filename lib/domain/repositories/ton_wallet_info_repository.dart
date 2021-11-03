import '../models/ton_wallet_info.dart';

abstract class TonWalletInfoRepository {
  TonWalletInfo? get(String address);

  Future<void> save(TonWalletInfo tonWalletInfo);

  Future<void> remove(String address);

  Future<void> clear();
}
