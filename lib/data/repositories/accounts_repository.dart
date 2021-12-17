import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../services/nekoton_service.dart';
import 'ton_assets_repository.dart';

@lazySingleton
class AccountsRepository {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;

  AccountsRepository(
    this._nekotonService,
    this._tonAssetsRepository,
  );

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
  }) async {
    final assetsList = await _nekotonService.addTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
    );

    if (_tonAssetsRepository.assets.firstWhereOrNull((e) => e.address == rootTokenContract) == null) {
      final tokenWalletInfo = await _nekotonService.getTokenWalletInfo(
        address: address,
        rootTokenContract: rootTokenContract,
      );

      await _tonAssetsRepository.saveCustom(
        name: tokenWalletInfo.symbol.fullName,
        symbol: tokenWalletInfo.symbol.name,
        decimals: tokenWalletInfo.symbol.decimals,
        address: tokenWalletInfo.symbol.rootTokenContract,
        version: tokenWalletInfo.version.index + 1,
      );
    }

    return assetsList;
  }

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekotonService.removeTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );
}
