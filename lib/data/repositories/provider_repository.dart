import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart'
    hide
        runLocal,
        getExpectedAddress,
        packIntoCell,
        unpackFromCell,
        extractPublicKey,
        codeToTvc,
        splitTvc,
        encodeInternalInput,
        decodeInput,
        decodeOutput,
        decodeEvent,
        decodeTransaction,
        decodeTransactionEvents,
        parseKnownPayload,
        createExternalMessage;
import 'package:nekoton_flutter/nekoton_flutter.dart' as provider_utils
    show
        runLocal,
        getExpectedAddress,
        packIntoCell,
        unpackFromCell,
        extractPublicKey,
        codeToTvc,
        splitTvc,
        encodeInternalInput,
        decodeInput,
        decodeOutput,
        decodeEvent,
        decodeTransaction,
        decodeTransactionEvents,
        parseKnownPayload,
        createExternalMessage;
import 'package:rxdart/rxdart.dart';

import '../constants.dart';
import '../utils.dart';
import 'approvals_repository.dart';
import 'generic_contracts_subscriptions_repository.dart';
import 'keystore_repository.dart';
import 'permissions_repository.dart';
import 'ton_wallets_subscriptions_repository.dart';
import 'transport_repository.dart';

@lazySingleton
class ProviderRepository {
  final GenericContractsSubscriptionsRepository _genericContractsSubscriptionsRepository;
  final TonWalletsSubscriptionsRepository _tonWalletsSubscriptionsRepository;
  final TransportRepository _transportRepository;
  final PermissionsRepository _permissionsRepository;
  final KeystoreRepository _keystoreRepository;
  final ApprovalsRepository _approvalsRepository;
  final _disconnectedSubject = PublishSubject<Error>();

  ProviderRepository(
    this._genericContractsSubscriptionsRepository,
    this._tonWalletsSubscriptionsRepository,
    this._transportRepository,
    this._permissionsRepository,
    this._keystoreRepository,
    this._approvalsRepository,
  );

  Stream<Error> get disconnectedStream => _disconnectedSubject.stream;

  Stream<TransactionsFoundEvent> get transactionsFoundStream =>
      _genericContractsSubscriptionsRepository.genericContractsStream
          .map((e) => e.values)
          .expand((e) => e)
          .expand((e) => e)
          .flatMap(
            (e) => e.onTransactionsFoundStream.map(
              (el) => TransactionsFoundEvent(
                address: e.address,
                transactions: el.transactions,
                info: el.batchInfo,
              ),
            ),
          );

  Stream<ContractStateChangedEvent> get contractStateChangedStream =>
      _genericContractsSubscriptionsRepository.genericContractsStream
          .map((e) => e.values)
          .expand((e) => e)
          .expand((e) => e)
          .flatMap(
            (e) => e.onStateChangedStream.map(
              (el) => ContractStateChangedEvent(
                address: e.address,
                state: el.newState,
              ),
            ),
          );

  Stream<NetworkChangedEvent> get networkChangedStream => _transportRepository.transportStream.map(
        (e) => NetworkChangedEvent(
          selectedConnection: e.connectionData.name,
        ),
      );

  Stream<PermissionsChangedEvent> get permissionsChangedStream => _permissionsRepository.permissionsStream.map(
        (e) => PermissionsChangedEvent(
          permissions: e,
        ),
      );

  Stream<Object> get loggedOutStream => _keystoreRepository.keysStream.where((e) => e.isNotEmpty).map((e) => Object());

  Future<RequestPermissionsOutput> requestPermissions({
    required String origin,
    required RequestPermissionsInput input,
  }) =>
      _permissionsRepository.requestPermissions(
        origin: origin,
        permissions: input.permissions,
      );

  Future<void> disconnect({
    required String origin,
  }) async {
    await _permissionsRepository.removeOrigin(origin);
    await _genericContractsSubscriptionsRepository.removeOriginGenericContractSubscriptions(origin);
  }

  Future<SubscribeOutput> subscribe({
    required String origin,
    required SubscribeInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    if (!validateAddress(input.address)) {
      throw Exception();
    }

    await _genericContractsSubscriptionsRepository.subscribeToGenericContract(
      origin: origin,
      address: input.address,
    );

    return const ContractUpdatesSubscription(
      state: true,
      transactions: true,
    );
  }

  Future<void> unsubscribe({
    required String origin,
    required UnsubscribeInput input,
  }) async {
    if (!validateAddress(input.address)) {
      throw Exception();
    }

    await _genericContractsSubscriptionsRepository.removeGenericContractSubscription(
      origin: origin,
      address: input.address,
    );
  }

  Future<void> unsubscribeAll({
    required String origin,
  }) async {
    await _genericContractsSubscriptionsRepository.clearGenericContractsSubscriptions();
  }

  Future<GetProviderStateOutput> getProviderState({
    required String origin,
  }) async {
    await _genericContractsSubscriptionsRepository.clearGenericContractsSubscriptions();

    const version = kProviderVersion;
    final numericVersion = kProviderVersion.toInt();
    final selectedConnection = _transportRepository.transport.connectionData.name;
    final permissions = _permissionsRepository.getPermissions(origin);
    final subscriptions = _genericContractsSubscriptionsRepository.getOriginSubscriptions(origin);

    return GetProviderStateOutput(
      version: version,
      numericVersion: numericVersion,
      selectedConnection: selectedConnection,
      permissions: permissions,
      subscriptions: subscriptions,
    );
  }

  Future<GetFullContractStateOutput> getFullContractState({
    required String origin,
    required GetFullContractStateInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final state = await _transportRepository.transport.getFullAccountState(address: input.address);

    return GetFullContractStateOutput(
      state: state,
    );
  }

  Future<GetTransactionsOutput> getTransactions({
    required String origin,
    required GetTransactionsInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final getTransactionsOutput = await _transportRepository.transport.getTransactions(
      address: input.address,
      continuation: input.continuation,
      limit: input.limit,
    );

    return getTransactionsOutput;
  }

  Future<RunLocalOutput> runLocal({
    required String origin,
    required RunLocalInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    FullContractState? contractState = input.cachedState;

    if (input.cachedState == null) {
      contractState = await _transportRepository.transport.getFullAccountState(address: input.address);
    }

    if (contractState == null) {
      throw Exception();
    }

    if (!contractState.isDeployed) {
      throw Exception();
    }

    return provider_utils.runLocal(
      accountStuffBoc: contractState.boc,
      contractAbi: input.functionCall.abi,
      method: input.functionCall.method,
      input: input.functionCall.params,
    );
  }

  Future<GetExpectedAddressOutput> getExpectedAddress({
    required String origin,
    required GetExpectedAddressInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final address = provider_utils.getExpectedAddress(
      tvc: input.tvc,
      contractAbi: input.abi,
      workchainId: input.workchain,
      publicKey: input.publicKey,
      initData: input.initParams,
    );

    return GetExpectedAddressOutput(
      address: address,
    );
  }

  Future<PackIntoCellOutput> packIntoCell({
    required String origin,
    required PackIntoCellInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final boc = provider_utils.packIntoCell(
      params: input.structure,
      tokens: input.data,
    );

    return PackIntoCellOutput(
      boc: boc,
    );
  }

  Future<UnpackFromCellOutput> unpackFromCell({
    required String origin,
    required UnpackFromCellInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final data = provider_utils.unpackFromCell(
      params: input.structure,
      boc: input.boc,
      allowPartial: input.allowPartial,
    );

    return UnpackFromCellOutput(
      data: data,
    );
  }

  Future<ExtractPublicKeyOutput> extractPublicKey({
    required String origin,
    required ExtractPublicKeyInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final publicKey = provider_utils.extractPublicKey(input.boc);

    return ExtractPublicKeyOutput(
      publicKey: publicKey,
    );
  }

  Future<CodeToTvcOutput> codeToTvc({
    required String origin,
    required CodeToTvcInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final tvc = provider_utils.codeToTvc(input.code);

    return CodeToTvcOutput(
      tvc: tvc,
    );
  }

  Future<SplitTvcOutput> splitTvc({
    required String origin,
    required SplitTvcInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    return provider_utils.splitTvc(input.tvc);
  }

  Future<EncodeInternalInputOutput> encodeInternalInput({
    required String origin,
    required EncodeInternalInputInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final boc = provider_utils.encodeInternalInput(
      contractAbi: input.abi,
      method: input.method,
      input: input.params,
    );

    return EncodeInternalInputOutput(
      boc: boc,
    );
  }

  Future<DecodeInputOutput?> decodeInput({
    required String origin,
    required DecodeInputInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    return provider_utils.decodeInput(
      messageBody: input.body,
      contractAbi: input.abi,
      method: input.method,
      internal: input.internal,
    );
  }

  Future<DecodeOutputOutput?> decodeOutput({
    required String origin,
    required DecodeOutputInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    return provider_utils.decodeOutput(
      messageBody: input.body,
      contractAbi: input.abi,
      method: input.method,
    );
  }

  Future<DecodeEventOutput?> decodeEvent({
    required String origin,
    required DecodeEventInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    return provider_utils.decodeEvent(
      messageBody: input.body,
      contractAbi: input.abi,
      event: input.event,
    );
  }

  Future<DecodeTransactionOutput?> decodeTransaction({
    required String origin,
    required DecodeTransactionInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    return provider_utils.decodeTransaction(
      transaction: input.transaction,
      contractAbi: input.abi,
      method: input.method,
    );
  }

  Future<DecodeTransactionEventsOutput> decodeTransactionEvents({
    required String origin,
    required DecodeTransactionEventsInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.tonClient],
    );

    final events = provider_utils.decodeTransactionEvents(
      transaction: input.transaction,
      contractAbi: input.abi,
    );

    return DecodeTransactionEventsOutput(
      events: events,
    );
  }

  Future<EstimateFeesOutput> estimateFees({
    required String origin,
    required EstimateFeesInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = _permissionsRepository.getPermissions(origin);
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.address != input.sender) {
      throw Exception();
    }

    final selectedAddress = allowedAccount!.address;
    final repackedRecipient = repackAddress(input.recipient);

    String? body;
    if (input.payload != null) {
      body = provider_utils.encodeInternalInput(
        contractAbi: input.payload!.abi,
        method: input.payload!.method,
        input: input.payload!.params,
      );
    }

    final tonWallet =
        _tonWalletsSubscriptionsRepository.tonWallets.firstWhereOrNull((e) => e.address == selectedAddress);

    if (tonWallet == null) {
      throw Exception();
    }

    final unsignedMessage = await tonWallet.prepareTransfer(
      publicKey: tonWallet.publicKey,
      expiration: kDefaultMessageExpiration,
      destination: repackedRecipient,
      amount: input.amount,
      body: body,
      isComment: false,
    );

    final fees = await tonWallet.estimateFees(unsignedMessage);

    return EstimateFeesOutput(
      fees: fees,
    );
  }

  Future<SendMessageOutput> sendMessage({
    required String origin,
    required SendMessageInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = _permissionsRepository.getPermissions(origin);
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.address != input.sender) {
      throw Exception();
    }

    final selectedAddress = allowedAccount!.address;
    final repackedRecipient = repackAddress(input.recipient);

    String? body;
    KnownPayload? knownPayload;
    if (input.payload != null) {
      body = provider_utils.encodeInternalInput(
        contractAbi: input.payload!.abi,
        method: input.payload!.method,
        input: input.payload!.params,
      );
      knownPayload = provider_utils.parseKnownPayload(body);
    }

    final tuple = await _approvalsRepository.requestApprovalToSendMessage(
      origin: origin,
      sender: selectedAddress,
      recipient: repackedRecipient,
      amount: input.amount,
      bounce: input.bounce,
      payload: input.payload,
      knownPayload: knownPayload,
    );

    final publicKey = tuple.item1;
    final password = tuple.item2;

    final tonWallet =
        _tonWalletsSubscriptionsRepository.tonWallets.firstWhereOrNull((e) => e.address == selectedAddress);

    if (tonWallet == null) {
      throw Exception();
    }

    final message = await tonWallet.prepareTransfer(
      publicKey: publicKey,
      expiration: kDefaultMessageExpiration,
      destination: repackedRecipient,
      amount: input.amount,
      body: body,
      isComment: false,
    );

    final key = _keystoreRepository.keys.firstWhere((e) => e.publicKey == publicKey);

    final signInput = key.isLegacy
        ? EncryptedKeyPassword(
            publicKey: key.publicKey,
            password: Password.explicit(
              password: password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          )
        : DerivedKeySignParams.byAccountId(
            masterKey: key.masterKey,
            accountId: key.accountId,
            password: Password.explicit(
              password: password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );

    final pendingTransaction = await tonWallet.send(
      keystore: _keystoreRepository.keystore,
      message: message,
      signInput: signInput,
    );

    await message.freePtr();

    final transaction = await tonWallet.onMessageSentStream
        .firstWhere((e) => e.pendingTransaction == pendingTransaction)
        .then((v) => v.transaction!);

    return SendMessageOutput(
      transaction: transaction,
    );
  }

  Future<SendExternalMessageOutput> sendExternalMessage({
    required String origin,
    required SendExternalMessageInput input,
  }) async {
    await _permissionsRepository.checkPermissions(
      origin: origin,
      requiredPermissions: [Permission.accountInteraction],
    );

    final permissions = _permissionsRepository.getPermissions(origin);
    final allowedAccount = permissions.accountInteraction;

    if (allowedAccount?.publicKey != input.publicKey) {
      throw Exception();
    }

    final selectedPublicKey = allowedAccount!.publicKey;
    final selectedAddress = allowedAccount.address;
    final repackedRecipient = repackAddress(input.recipient);

    final genericContract = _genericContractsSubscriptionsRepository.genericContracts[origin]
        ?.firstWhereOrNull((e) => e.address == selectedAddress);

    if (genericContract == null) {
      throw Exception();
    }

    final message = provider_utils.createExternalMessage(
      dst: repackedRecipient,
      contractAbi: input.payload.abi,
      method: input.payload.method,
      stateInit: input.stateInit,
      input: input.payload.params,
      publicKey: selectedPublicKey,
      timeout: 30,
    );

    final password = await _approvalsRepository.requestApprovalToCallContractMethod(
      origin: origin,
      selectedPublicKey: selectedPublicKey,
      repackedRecipient: repackedRecipient,
      payload: input.payload,
    );

    Transaction transaction;
    if (input.local == true) {
      final key = _keystoreRepository.keys.firstWhere((e) => e.publicKey == selectedPublicKey);

      final signInput = key.isLegacy
          ? EncryptedKeyPassword(
              publicKey: key.publicKey,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            )
          : DerivedKeySignParams.byAccountId(
              masterKey: key.masterKey,
              accountId: key.accountId,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );

      transaction = await genericContract.executeTransactionLocally(
        keystore: _keystoreRepository.keystore,
        message: message,
        signInput: signInput,
        options: const TransactionExecutionOptions(disableSignatureCheck: false),
      );
    } else {
      final key = _keystoreRepository.keys.firstWhere((e) => e.publicKey == selectedPublicKey);

      final signInput = key.isLegacy
          ? EncryptedKeyPassword(
              publicKey: key.publicKey,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            )
          : DerivedKeySignParams.byAccountId(
              masterKey: key.masterKey,
              accountId: key.accountId,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );

      final pendingTransaction = await genericContract.send(
        keystore: _keystoreRepository.keystore,
        message: message,
        signInput: signInput,
      );

      await message.freePtr();

      transaction = await genericContract.onMessageSentStream
          .firstWhere((e) => e.pendingTransaction == pendingTransaction)
          .then((v) => v.transaction!);
    }

    TokensObject output;
    try {
      final decoded = provider_utils.decodeTransaction(
        transaction: transaction,
        contractAbi: input.payload.abi,
        method: input.payload.method,
      );
      output = decoded?.output;
    } catch (_) {}

    return SendExternalMessageOutput(
      transaction: transaction,
      output: output,
    );
  }
}
