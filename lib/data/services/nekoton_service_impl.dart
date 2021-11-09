import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/services/nekoton_service.dart';
import '../../logger.dart';

@preResolve
@LazySingleton(as: NekotonService)
class NekotonServiceImpl implements NekotonService {
  late final Nekoton _nekoton;

  NekotonServiceImpl._();

  @factoryMethod
  static Future<NekotonServiceImpl> create() async {
    final nekotonService = NekotonServiceImpl._();
    await nekotonService._initialize();
    return nekotonService;
  }

  @override
  Stream<Transport> get transportStream => _nekoton.connectionController.transportStream;

  @override
  Transport get transport => _nekoton.connectionController.transport;

  @override
  Future<void> updateTransport(ConnectionData connectionData) =>
      _nekoton.connectionController.updateTransport(connectionData);

  @override
  Stream<List<KeyStoreEntry>> get keysStream => _nekoton.keystoreController.keysStream;

  @override
  Stream<List<AssetsList>> get accountsStream => _nekoton.accountsStorageController.accountsStream;

  @override
  Stream<List<TonWallet>> get tonWalletsStream => _nekoton.subscriptionsController.tonWalletsStream;

  @override
  Stream<List<TokenWallet>> get tokenWalletsStream => _nekoton.subscriptionsController.tokenWalletsStream;

  @override
  Stream<KeyStoreEntry?> get currentKeyStream => _nekoton.keystoreController.currentKeyStream;

  @override
  Stream<bool> get keysPresenceStream => _nekoton.keystoreController.keysStream
      .transform<bool>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) => sink.add(data.isNotEmpty),
        ),
      )
      .distinct();

  @override
  List<KeyStoreEntry> get keys => _nekoton.keystoreController.keys;

  @override
  List<AssetsList> get accounts => _nekoton.accountsStorageController.accounts;

  @override
  List<TonWallet> get tonWallets => _nekoton.subscriptionsController.tonWallets;

  @override
  List<TokenWallet> get tokenWallets => _nekoton.subscriptionsController.tokenWallets;

  @override
  KeyStoreEntry? get currentKey => _nekoton.keystoreController.currentKey;

  @override
  set currentKey(KeyStoreEntry? currentKey) => _nekoton.keystoreController.currentKey = currentKey;

  @override
  String get networkGroup => _nekoton.connectionController.transport.connectionData.group;

  @override
  Future<KeyStoreEntry> addKey(CreateKeyInput createKeyInput) => _nekoton.keystoreController.addKey(createKeyInput);

  @override
  Future<KeyStoreEntry> updateKey(UpdateKeyInput updateKeyInput) =>
      _nekoton.keystoreController.updateKey(updateKeyInput);

  @override
  Future<ExportKeyOutput> exportKey(ExportKeyInput exportKeyInput) =>
      _nekoton.keystoreController.exportKey(exportKeyInput);

  @override
  Future<bool> checkKeyPassword(SignInput signInput) => _nekoton.keystoreController.checkKeyPassword(signInput);

  @override
  Future<KeyStoreEntry?> removeKey(String publicKey) => _nekoton.keystoreController.removeKey(publicKey);

  @override
  Future<void> clearKeystore() => _nekoton.keystoreController.clearKeystore();

  @override
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

  @override
  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) =>
      _nekoton.accountsStorageController.renameAccount(
        address: address,
        name: name,
      );

  @override
  Future<AssetsList?> removeAccount(String address) => _nekoton.accountsStorageController.removeAccount(address);

  @override
  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.accountsStorageController.addTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.accountsStorageController.removeTokenWallet(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  @override
  Future<void> clearAccountsStorage() => _nekoton.accountsStorageController.clearAccountsStorage();

  @override
  Future<RootTokenContractInfo> getTokenWalletInfo({
    required String address,
    required String rootTokenContract,
  }) =>
      _nekoton.subscriptionsController.getTokenWalletInfo(
        address: address,
        rootTokenContract: rootTokenContract,
      );

  @override
  Stream<ApprovalRequest> get approvalStream => _nekoton.approvalController.approvalStream;

  Future<void> _initialize() async {
    _nekoton = await Nekoton.getInstance(
      logger: logger,
    );
  }
}
