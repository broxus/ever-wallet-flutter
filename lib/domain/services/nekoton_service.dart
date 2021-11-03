import 'package:nekoton_flutter/nekoton_flutter.dart';

abstract class NekotonService {
  Stream<Transport> get transportStream;

  Transport get transport;

  Stream<List<KeyStoreEntry>> get keysStream;

  Stream<List<AssetsList>> get accountsStream;

  Stream<List<TonWallet>> get tonWalletsStream;

  Stream<List<TokenWallet>> get tokenWalletsStream;

  Stream<KeyStoreEntry?> get currentKeyStream;

  Stream<bool> get keysPresenceStream;

  List<KeyStoreEntry> get keys;

  List<AssetsList> get accounts;

  List<TonWallet> get tonWallets;

  List<TokenWallet> get tokenWallets;

  KeyStoreEntry? get currentKey;

  set currentKey(KeyStoreEntry? currentKey);

  String get networkGroup;

  Future<KeyStoreEntry> addKey(CreateKeyInput createKeyInput);

  Future<KeyStoreEntry> updateKey(UpdateKeyInput updateKeyInput);

  Future<ExportKeyOutput> exportKey(ExportKeyInput exportKeyInput);

  Future<bool> checkKeyPassword(SignInput signInput);

  Future<KeyStoreEntry?> removeKey(String publicKey);

  Future<void> clearKeystore();

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
    required int workchain,
  });

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  });

  Future<AssetsList?> removeAccount(String address);

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  });

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  });

  Future<void> clearAccountsStorage();

  Future<RootTokenContractInfo> getTokenWalletInfo({
    required String address,
    required String rootTokenContract,
  });

  Stream<ApprovalRequest> get approvalStream;
}
