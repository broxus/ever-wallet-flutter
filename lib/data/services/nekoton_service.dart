import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../logger.dart';

@preResolve
@lazySingleton
class NekotonService {
  late final Nekoton _nekoton;

  NekotonService._();

  @factoryMethod
  static Future<NekotonService> create() async {
    final nekotonService = NekotonService._();
    await nekotonService._initialize();
    return nekotonService;
  }

  Stream<Transport> get transportStream => _nekoton.connectionController.transportStream;

  Transport get transport => _nekoton.connectionController.transport;

  Future<void> updateTransport(ConnectionData connectionData) =>
      _nekoton.connectionController.updateTransport(connectionData);

  Stream<List<KeyStoreEntry>> get keysStream => _nekoton.keystoreController.keysStream;

  Stream<List<AssetsList>> get accountsStream => _nekoton.accountsStorageController.accountsStream;

  Stream<List<TonWallet>> get tonWalletsStream => _nekoton.subscriptionsController.tonWalletsStream;

  Stream<List<TokenWallet>> get tokenWalletsStream => _nekoton.subscriptionsController.tokenWalletsStream;

  Stream<KeyStoreEntry?> get currentKeyStream => _nekoton.keystoreController.currentKeyStream;

  Stream<bool> get keysPresenceStream => _nekoton.keystoreController.keysStream
      .transform<bool>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) => sink.add(data.isNotEmpty),
        ),
      )
      .distinct();

  List<KeyStoreEntry> get keys => _nekoton.keystoreController.keys;

  List<AssetsList> get accounts => _nekoton.accountsStorageController.accounts;

  List<TonWallet> get tonWallets => _nekoton.subscriptionsController.tonWallets;

  List<TokenWallet> get tokenWallets => _nekoton.subscriptionsController.tokenWallets;

  KeyStoreEntry? get currentKey => _nekoton.keystoreController.currentKey;

  set currentKey(KeyStoreEntry? currentKey) => _nekoton.keystoreController.currentKey = currentKey;

  String get networkGroup => _nekoton.connectionController.transport.connectionData.group;

  Future<KeyStoreEntry> addKey(CreateKeyInput createKeyInput) => _nekoton.keystoreController.addKey(createKeyInput);

  Future<KeyStoreEntry> updateKey(UpdateKeyInput updateKeyInput) =>
      _nekoton.keystoreController.updateKey(updateKeyInput);

  Future<ExportKeyOutput> exportKey(ExportKeyInput exportKeyInput) =>
      _nekoton.keystoreController.exportKey(exportKeyInput);

  Future<bool> checkKeyPassword(SignInput signInput) => _nekoton.keystoreController.checkKeyPassword(signInput);

  Future<KeyStoreEntry?> removeKey(String publicKey) => _nekoton.keystoreController.removeKey(publicKey);

  Future<void> clearKeystore() => _nekoton.keystoreController.clearKeystore();

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
    required int workchain,
  }) =>
      _nekoton.accountsStorageController.addAccount(
        name: name,
        publicKey: publicKey,
        walletType: walletType,
        workchain: workchain,
      );

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) =>
      _nekoton.accountsStorageController.renameAccount(
        address: address,
        name: name,
      );

  Future<AssetsList?> removeAccount(String address) => _nekoton.accountsStorageController.removeAccount(address);

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.accountsStorageController.addTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.accountsStorageController.removeTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  Future<void> clearAccountsStorage() => _nekoton.accountsStorageController.clearAccountsStorage();

  Future<RootTokenContractInfo> getTokenWalletInfo({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.subscriptionsController.getTokenWalletInfo(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  Stream<ApprovalRequest> get approvalStream => _nekoton.approvalController.approvalStream;

  Future<void> _initialize() async {
    _nekoton = await Nekoton.getInstance(
      logger: logger,
    );
  }
}
