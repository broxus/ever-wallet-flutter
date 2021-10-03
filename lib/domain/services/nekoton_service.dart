import 'package:nekoton_flutter/nekoton_flutter.dart';

abstract class NekotonService {
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

  Stream<ApprovalRequest> get approvalStream;

  Stream<Error> get providerDisconnectedStream;

  Stream<TransactionsFoundEvent> get providerTransactionsFoundStream;

  Stream<ContractStateChangedEvent> get providerContractStateChangedStream;

  Stream<NetworkChangedEvent> get providerNetworkChangedStream;

  Stream<PermissionsChangedEvent> get providerPermissionsChangedStream;

  Stream<Object> get providerLoggedOutStream;

  Future<RequestPermissionsOutput> providerRequestPermissions({
    required String origin,
    required RequestPermissionsInput input,
  });

  Future<void> providerDisconnect({
    required String origin,
  });

  Future<SubscribeOutput> providerSubscribe({
    required String origin,
    required SubscribeInput input,
  });

  void providerUnsubscribe({
    required String origin,
    required UnsubscribeInput input,
  });

  void providerUnsubscribeAll({
    required String origin,
  });

  Future<GetProviderStateOutput> providerGetProviderState({
    required String origin,
  });

  Future<GetFullContractStateOutput> providerGetFullContractState({
    required String origin,
    required GetFullContractStateInput input,
  });

  Future<GetTransactionsOutput> providerGetTransactions({
    required String origin,
    required GetTransactionsInput input,
  });

  Future<RunLocalOutput> providerRunLocal({
    required String origin,
    required RunLocalInput input,
  });

  Future<GetExpectedAddressOutput> providerGetExpectedAddress({
    required String origin,
    required GetExpectedAddressInput input,
  });

  Future<PackIntoCellOutput> providerPackIntoCell({
    required String origin,
    required PackIntoCellInput input,
  });

  Future<UnpackFromCellOutput> providerUnpackFromCell({
    required String origin,
    required UnpackFromCellInput input,
  });

  Future<ExtractPublicKeyOutput> providerExtractPublicKey({
    required String origin,
    required ExtractPublicKeyInput input,
  });

  Future<CodeToTvcOutput> providerCodeToTvc({
    required String origin,
    required CodeToTvcInput input,
  });

  Future<SplitTvcOutput> providerSplitTvc({
    required String origin,
    required SplitTvcInput input,
  });

  Future<EncodeInternalInputOutput> providerEncodeInternalInput({
    required String origin,
    required EncodeInternalInputInput input,
  });

  Future<DecodeInputOutput?> providerDecodeInput({
    required String origin,
    required DecodeInputInput input,
  });

  Future<DecodeOutputOutput?> providerDecodeOutput({
    required String origin,
    required DecodeOutputInput input,
  });

  Future<DecodeEventOutput?> providerDecodeEvent({
    required String origin,
    required DecodeEventInput input,
  });

  Future<DecodeTransactionOutput?> providerDecodeTransaction({
    required String origin,
    required DecodeTransactionInput input,
  });

  Future<DecodeTransactionEventsOutput> providerDecodeTransactionEvents({
    required String origin,
    required DecodeTransactionEventsInput input,
  });

  Future<EstimateFeesOutput> providerEstimateFees({
    required String origin,
    required EstimateFeesInput input,
  });

  Future<SendMessageOutput> providerSendMessage({
    required String origin,
    required SendMessageInput input,
  });

  Future<SendExternalMessageOutput> providerSendExternalMessage({
    required String origin,
    required SendExternalMessageInput input,
  });
}
