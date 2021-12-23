import 'package:injectable/injectable.dart';

import '../services/nekoton_service.dart';

@lazySingleton
class ExternalAccountsRepository {
  final NekotonService _nekotonService;

  ExternalAccountsRepository(this._nekotonService);

  Future<void> addExternalAccount({
    required String address,
    String? name,
  }) =>
      _nekotonService.addExternalAccount(
        publicKey: _nekotonService.currentKey!.publicKey,
        address: address,
        name: name,
      );

  Future<void> removeExternalAccount(String address) => _nekotonService.removeExternalAccount(
        publicKey: _nekotonService.currentKey!.publicKey,
        address: address,
      );
}
