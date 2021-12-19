import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../exceptions.dart';
import '../services/nekoton_service.dart';
import 'ton_assets_repository.dart';

@lazySingleton
class ExternalAccountsRepository {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;

  ExternalAccountsRepository(
    this._nekotonService,
    this._tonAssetsRepository,
  );

  Future<AssetsList> addExternalAccount({
    required String address,
    String? name,
  }) async {
    if (_nekotonService.accounts
        .where((e) => e.publicKey == _nekotonService.currentKey?.publicKey)
        .any((e) => e.address == address)) {
      throw AccountAlreadyAddedException();
    }

    final info = await _nekotonService.getTonWalletInfo(address);

    final assetsList = AssetsList(
      name: name ?? info.walletType.describe(),
      tonWallet: TonWalletAsset(
        address: info.address,
        publicKey: info.publicKey,
        contract: info.walletType,
      ),
      additionalAssets: {},
    );

    await _nekotonService.addExternalAccount(
      publicKey: _nekotonService.currentKey!.publicKey,
      assetsList: assetsList,
    );

    return assetsList;
  }

  Future<AssetsList> renameExternalAccount({
    required String address,
    required String name,
  }) async =>
      _nekotonService.renameExternalAccount(
        publicKey: _nekotonService.currentKey!.publicKey,
        address: address,
        name: name,
      );

  Future<AssetsList?> removeExternalAccount({
    required String address,
  }) async =>
      _nekotonService.removeExternalAccount(
        publicKey: _nekotonService.currentKey!.publicKey,
        address: address,
      );

  Future<AssetsList> addExternalAccountTokenWallet({
    required String publicKey,
    required String address,
    required String rootTokenContract,
  }) async {
    final assetsList = await _nekotonService.addExternalAccountTokenWallet(
      publicKey: publicKey,
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

  Future<AssetsList> removeExternalAccountTokenWallet({
    required String publicKey,
    required String address,
    required String rootTokenContract,
  }) =>
      _nekotonService.removeExternalAccountTokenWallet(
        publicKey: publicKey,
        address: address,
        rootTokenContract: rootTokenContract,
      );
}
