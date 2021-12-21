import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../services/nekoton_service.dart';

@lazySingleton
class ExternalAccountsRepository {
  final NekotonService _nekotonService;

  ExternalAccountsRepository(this._nekotonService);

  Future<void> addExternalAccount({
    required String address,
    String? name,
  }) async {
    await _nekotonService.addExternalAccount(
      publicKey: _nekotonService.currentKey!.publicKey,
      address: address,
    );

    if (name != null) {
      await _nekotonService.accountsStream
          .firstWhere((e) => e.any((e) => e.address == address))
          .timeout(kRequestTimeout);

      await _nekotonService.renameAccount(
        address: address,
        name: name,
      );
    }
  }

  Future<void> removeExternalAccount(String address) async => _nekotonService.removeExternalAccount(
        publicKey: _nekotonService.currentKey!.publicKey,
        address: address,
      );
}
