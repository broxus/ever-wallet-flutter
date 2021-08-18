import 'package:nekoton_flutter/nekoton_flutter.dart';

abstract class NekotonService {
  Stream<List<KeySubject>> get keysStream;

  Stream<List<AccountSubject>> get accountsStream;

  Stream<List<SubscriptionSubject>> get subscriptionsStream;

  Stream<KeySubject?> get currentKeyStream;

  Stream<bool> get keysPresenceStream;

  Stream<bool> get accountsPresenceStream;

  Stream<bool> get subscriptionsPresenceStream;

  List<KeySubject> get keys;

  List<AccountSubject> get accounts;

  List<SubscriptionSubject> get subscriptions;

  KeySubject? get currentKey;

  Future<void> setCurrentKey(KeySubject? currentKey);

  Future<KeySubject> addKey(CreateKeyInput createKeyInput);

  Future<KeySubject> updateKey(UpdateKeyInput updateKeyInput);

  Future<ExportKeyOutput> exportKey(ExportKeyInput exportKeyInput);

  Future<bool> checkKeyPassword(SignInput signInput);

  Future<KeySubject?> removeKey(String publicKey);

  Future<void> clearKeystore();

  Future<AccountSubject> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
  });

  Future<AccountSubject> renameAccount({
    required String address,
    required String name,
  });

  Future<AccountSubject?> removeAccount(String address);

  Future<AccountSubject> addTokenWallet({
    required String address,
    required String rootTokenContract,
  });

  Future<AccountSubject> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  });

  Future<void> clearAccountsStorage();
}
