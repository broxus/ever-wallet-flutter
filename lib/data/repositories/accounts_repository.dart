import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../services/nekoton_service.dart';

@lazySingleton
class AccountsRepository {
  final NekotonService _nekotonService;

  AccountsRepository(this._nekotonService);

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) =>
      _nekotonService.addAccount(
        name: name,
        publicKey: publicKey,
        walletType: walletType,
        workchain: kDefaultWorkchain,
      );

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) =>
      _nekotonService.renameAccount(
        address: address,
        name: name,
      );

  Future<AssetsList?> removeAccount(String address) => _nekotonService.removeAccount(address);

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekotonService.addTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekotonService.removeTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );
}
