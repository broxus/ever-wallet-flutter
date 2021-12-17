import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../exceptions.dart';
import '../services/nekoton_service.dart';

@lazySingleton
class ExternalAccountsRepository {
  final NekotonService _nekotonService;

  ExternalAccountsRepository(this._nekotonService);

  Future<AssetsList> addExternalAccount({
    required String publicKey,
    required String address,
    String? name,
  }) async {
    if (_nekotonService.accounts.any((e) => e.address == address)) {
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
      publicKey: publicKey,
      assetsList: assetsList,
    );

    return assetsList;
  }

  Future<AssetsList> renameExternalAccount({
    required String publicKey,
    required String address,
    required String name,
  }) async =>
      _nekotonService.renameExternalAccount(
        publicKey: publicKey,
        address: address,
        name: name,
      );

  Future<AssetsList?> removeExternalAccount({
    required String publicKey,
    required String address,
  }) async =>
      _nekotonService.removeExternalAccount(
        publicKey: publicKey,
        address: address,
      );
}
