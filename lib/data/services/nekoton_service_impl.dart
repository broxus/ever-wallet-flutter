import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/repositories/user_preferences_repository.dart';
import '../../domain/services/nekoton_service.dart';
import '../../logger.dart';

@preResolve
@LazySingleton(as: NekotonService)
class NekotonServiceImpl implements NekotonService {
  late final Nekoton _nekoton;
  late final UserPreferencesRepository _userPreferencesRepository;

  NekotonServiceImpl._(
    this._userPreferencesRepository,
  );

  @factoryMethod
  static Future<NekotonServiceImpl> create(
    UserPreferencesRepository userPreferencesRepository,
  ) async {
    final nekotonService = NekotonServiceImpl._(userPreferencesRepository);
    await nekotonService._initialize();
    return nekotonService;
  }

  @override
  Stream<List<KeySubject>> get keysStream => _nekoton.keysStream;

  @override
  Stream<List<AccountSubject>> get accountsStream => _nekoton.accountsStream;

  @override
  Stream<List<SubscriptionSubject>> get subscriptionsStream => _nekoton.subscriptionsStream;

  @override
  Stream<KeySubject?> get currentKeyStream => _nekoton.currentKeyStream;

  @override
  Stream<bool> get keysPresenceStream => _nekoton.keysPresenceStream;

  @override
  Stream<bool> get accountsPresenceStream => _nekoton.accountsPresenceStream;

  @override
  Stream<bool> get subscriptionsPresenceStream => _nekoton.subscriptionsPresenceStream;

  @override
  List<KeySubject> get keys => _nekoton.keys;

  @override
  List<AccountSubject> get accounts => _nekoton.accounts;

  @override
  List<SubscriptionSubject> get subscriptions => _nekoton.subscriptions;

  @override
  KeySubject? get currentKey => _nekoton.currentKey;

  @override
  Future<void> setCurrentKey(KeySubject? currentKey) async {
    final currentPublicKey = currentKey?.value.publicKey;

    await _userPreferencesRepository.setCurrentPublicKey(currentPublicKey);

    return _nekoton.setCurrentKey(currentKey);
  }

  @override
  Future<KeySubject> addKey(CreateKeyInput createKeyInput) => _nekoton.addKey(createKeyInput);

  @override
  Future<KeySubject> updateKey(UpdateKeyInput updateKeyInput) => _nekoton.updateKey(updateKeyInput);

  @override
  Future<ExportKeyOutput> exportKey(ExportKeyInput exportKeyInput) => _nekoton.exportKey(exportKeyInput);

  @override
  Future<bool> checkKeyPassword(SignInput signInput) => _nekoton.checkKeyPassword(signInput);

  @override
  Future<KeySubject?> removeKey(String publicKey) => _nekoton.removeKey(publicKey);

  @override
  Future<void> clearKeystore() => _nekoton.clearKeystore();

  @override
  Future<AccountSubject> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) =>
      _nekoton.addAccount(
        name: name,
        publicKey: publicKey,
        walletType: walletType,
      );

  @override
  Future<AccountSubject> renameAccount({
    required String address,
    required String name,
  }) =>
      _nekoton.renameAccount(
        address: address,
        name: name,
      );

  @override
  Future<AccountSubject?> removeAccount(String address) => _nekoton.removeAccount(address);

  @override
  Future<AccountSubject> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.addTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<AccountSubject> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.removeTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<void> clearAccountsStorage() => _nekoton.clearAccountsStorage();

  Future<void> _initialize() async {
    final currentPublicKey = await _userPreferencesRepository.currentPublicKey;

    _nekoton = await Nekoton.getInstance(
      logger: logger,
      currentPublicKey: currentPublicKey,
    );
  }
}
