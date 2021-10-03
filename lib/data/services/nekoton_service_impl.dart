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
  Stream<bool> get keysPresenceStream => _nekoton.keystoreController.keysStream.transform<bool>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) => sink.add(data.isNotEmpty),
        ),
      );

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
  Stream<ApprovalRequest> get approvalStream => _nekoton.approvalController.approvalStream;

  @override
  Stream<Error> get providerDisconnectedStream => disconnectedStream;

  @override
  Stream<TransactionsFoundEvent> get providerTransactionsFoundStream => transactionsFoundStream;

  @override
  Stream<ContractStateChangedEvent> get providerContractStateChangedStream => contractStateChangedStream;

  @override
  Stream<NetworkChangedEvent> get providerNetworkChangedStream => networkChangedStream;

  @override
  Stream<PermissionsChangedEvent> get providerPermissionsChangedStream => permissionsChangedStream;

  @override
  Stream<Object> get providerLoggedOutStream => loggedOutStream;

  @override
  Future<RequestPermissionsOutput> providerRequestPermissions({
    required String origin,
    required RequestPermissionsInput input,
  }) async =>
      requestPermissions(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<void> providerDisconnect({
    required String origin,
  }) async =>
      disconnect(
        instance: _nekoton,
        origin: origin,
      );

  @override
  Future<SubscribeOutput> providerSubscribe({
    required String origin,
    required SubscribeInput input,
  }) async =>
      subscribe(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  void providerUnsubscribe({
    required String origin,
    required UnsubscribeInput input,
  }) =>
      unsubscribe(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  void providerUnsubscribeAll({
    required String origin,
  }) =>
      unsubscribeAll(
        instance: _nekoton,
        origin: origin,
      );

  @override
  Future<GetProviderStateOutput> providerGetProviderState({
    required String origin,
  }) async =>
      getProviderState(
        instance: _nekoton,
        origin: origin,
      );

  @override
  Future<GetFullContractStateOutput> providerGetFullContractState({
    required String origin,
    required GetFullContractStateInput input,
  }) async =>
      getFullContractState(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<GetTransactionsOutput> providerGetTransactions({
    required String origin,
    required GetTransactionsInput input,
  }) async =>
      getTransactions(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<RunLocalOutput> providerRunLocal({
    required String origin,
    required RunLocalInput input,
  }) async =>
      runLocal(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<GetExpectedAddressOutput> providerGetExpectedAddress({
    required String origin,
    required GetExpectedAddressInput input,
  }) async =>
      getExpectedAddress(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<PackIntoCellOutput> providerPackIntoCell({
    required String origin,
    required PackIntoCellInput input,
  }) async =>
      packIntoCell(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<UnpackFromCellOutput> providerUnpackFromCell({
    required String origin,
    required UnpackFromCellInput input,
  }) async =>
      unpackFromCell(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<ExtractPublicKeyOutput> providerExtractPublicKey({
    required String origin,
    required ExtractPublicKeyInput input,
  }) async =>
      extractPublicKey(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<CodeToTvcOutput> providerCodeToTvc({
    required String origin,
    required CodeToTvcInput input,
  }) async =>
      codeToTvc(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<SplitTvcOutput> providerSplitTvc({
    required String origin,
    required SplitTvcInput input,
  }) async =>
      splitTvc(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<EncodeInternalInputOutput> providerEncodeInternalInput({
    required String origin,
    required EncodeInternalInputInput input,
  }) async =>
      encodeInternalInput(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<DecodeInputOutput?> providerDecodeInput({
    required String origin,
    required DecodeInputInput input,
  }) async =>
      decodeInput(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<DecodeOutputOutput?> providerDecodeOutput({
    required String origin,
    required DecodeOutputInput input,
  }) async =>
      decodeOutput(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<DecodeEventOutput?> providerDecodeEvent({
    required String origin,
    required DecodeEventInput input,
  }) async =>
      decodeEvent(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<DecodeTransactionOutput?> providerDecodeTransaction({
    required String origin,
    required DecodeTransactionInput input,
  }) async =>
      decodeTransaction(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<DecodeTransactionEventsOutput> providerDecodeTransactionEvents({
    required String origin,
    required DecodeTransactionEventsInput input,
  }) async =>
      decodeTransactionEvents(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<EstimateFeesOutput> providerEstimateFees({
    required String origin,
    required EstimateFeesInput input,
  }) async =>
      estimateFees(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<SendMessageOutput> providerSendMessage({
    required String origin,
    required SendMessageInput input,
  }) async =>
      sendMessage(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  @override
  Future<SendExternalMessageOutput> providerSendExternalMessage({
    required String origin,
    required SendExternalMessageInput input,
  }) async =>
      sendExternalMessage(
        instance: _nekoton,
        origin: origin,
        input: input,
      );

  Future<void> _initialize() async {
    _nekoton = await Nekoton.getInstance(
      logger: logger,
    );
  }
}
