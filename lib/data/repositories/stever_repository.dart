import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/main/browser/requests/models/send_message_input.dart';
import 'package:ever_wallet/data/models/stever/st_ever_details.dart';
import 'package:ever_wallet/data/models/stever/stever_withdraw_request.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

/// Paths to load stever abi
const _stEverAbiPath = 'assets/abi/StEverVault.abi.min.json';
const _stEverAccountAbiPath = 'assets/abi/StEverAccount.abi.min.json';

/// Address of stever contract to stake/unstake coins and call other methods
const stEverVault = '0:675a6d63f27e3f24d41d286043a9286b2e3eb6b84fa4c3308cc2833ef6f54d68';

/// Used to identify TokenWallet of user account of stever coin
const stEverRootContract = '0:6d42d0bc4a6568120ea88bf642edb653d727cfbd35868c47877532de128e71f2';

const stakeDepositAttachedFee = '2000000000'; // 2 EVER
const stakeRemovePendingWithdrawFee = '2000000000'; // 2 EVER
const stakeWithdrawAttachedFee = '3000000000'; // 3 EVER

typedef ContractAbiLoader = Future<String> Function(String path);

/// Repository that allows to communicate with StEver functionality from mobile app.
/// It allows stake/unstake tokens.
class StEverRepository {
  final GenericContractsRepository contractsRepository;
  final TonWalletsRepository tonWalletsRepository;
  final TransportSource transportSource;

  /// Json strings of contract abi that sends in requests
  final String stEverAbi;
  final String stEverAccountAbi;

  /// Withdraw request that was cancelled and mustn't be displayed when [userAvailableWithdraw]
  /// returns uncompleted list of blockchain messages.
  final _cancelledWithdraw = <String>[];

  final _withdrawSubject = BehaviorSubject<List<StEverWithdrawRequest>>();

  String? _walletChangesAddress;
  StreamSubscription? _walletChangesSubscription;

  static Future<StEverRepository> create({
    required GenericContractsRepository contractsRepository,
    required TransportSource transportSource,
    required TonWalletsRepository tonWalletsRepository,
    required ContractAbiLoader abiLoader,
  }) async {
    final instance = StEverRepository._(
      contractsRepository: contractsRepository,
      transportSource: transportSource,
      stEverAbi: await abiLoader(_stEverAbiPath),
      stEverAccountAbi: await abiLoader(_stEverAccountAbiPath),
      tonWalletsRepository: tonWalletsRepository,
    );

    return instance;
  }

  StEverRepository._({
    required this.contractsRepository,
    required this.transportSource,
    required this.stEverAbi,
    required this.stEverAccountAbi,
    required this.tonWalletsRepository,
  });

  /// Update withdraw requests list every time, stever contract get any transactions
  Stream<List<StEverWithdrawRequest>> withdrawRequestsStream(String accountAddress) {
    if (_walletChangesAddress != accountAddress) {
      _walletChangesAddress = accountAddress;
      _walletChangesSubscription?.cancel();
      _walletChangesSubscription = tonWalletsRepository
          .getTonWalletStream(accountAddress)
          .flatMap((wallet) => wallet.fieldUpdatesController)
          .listen((_) => _tryUpdateWithdraws(accountAddress));
      // empty list to avoid miss understanding while data not loaded
      _withdrawSubject.add([]);
      _tryUpdateWithdraws(accountAddress);
    }
    return _withdrawSubject.stream;
  }

  void _tryUpdateWithdraws(String accountAddress) {
    userAvailableWithdraw(_walletChangesAddress ?? '').then((withdraw) {
      if (_walletChangesAddress == accountAddress) {
        _withdrawSubject.add(withdraw);
      }
    }).catchError((_) {
      // ignore error
    });
  }

  /// Returns message input that should be handled with SendInfoPage
  SendMessageInput depositEver({
    required String accountAddress,
    required String depositAmount,
  }) {
    return SendMessageInput(
      recipient: stEverVault,
      sender: accountAddress,
      amount: (BigInt.parse(depositAmount) + BigInt.parse(stakeDepositAttachedFee)).toString(),
      bounce: false,
      payload: FunctionCall(
        method: 'deposit',
        abi: stEverAbi,
        params: {
          '_nonce': DateTime.now().millisecondsSinceEpoch,
          '_amount': depositAmount,
        },
      ),
    );
  }

  /// Returns payload for transferring token from TonWallet
  Future<String> withdrawStEver({
    required String accountAddress,
  }) async {
    final contract = await getVaultContractState();
    final result = runLocal(
      accountStuffBoc: contract.boc,
      contractAbi: stEverAbi,
      method: 'encodeDepositPayload',
      input: {
        '_nonce': DateTime.now().millisecondsSinceEpoch,
      },
      responsible: false,
    );
    return result.output?['depositPayload'] as String? ?? '';
  }

  /// Cancel withdraw request.
  /// Returns message input that should be handled with SendInfoPage
  SendMessageInput removeWithdraw({
    required String accountAddress,
    required String nonce,
  }) {
    return SendMessageInput(
      recipient: stEverVault,
      sender: accountAddress,
      amount: stakeRemovePendingWithdrawFee,
      bounce: false,
      payload: FunctionCall(
        method: 'removePendingWithdraw',
        abi: stEverAbi,
        params: {
          '_nonce': nonce,
        },
      ),
    );
  }

  /// Returns unstake requests that in progress
  Future<List<StEverWithdrawRequest>> userAvailableWithdraw(String accountAddress) async {
    final vaultState = await getVaultContractState();
    final result = runLocal(
      accountStuffBoc: vaultState.boc,
      contractAbi: stEverAbi,
      method: 'getAccountAddress',
      input: {'answerId': 0, '_user': accountAddress},
      responsible: false,
    );
    final address = result.output?.values.firstOrNull as String?;
    if (address == null) return [];

    try {
      /// This method can drop exception if there were no any transactions with stever and we ignore it
      final userState = await getUserContractState(address);
      final requestsResult = runLocal(
        accountStuffBoc: userState.boc,
        contractAbi: stEverAccountAbi,
        method: 'withdrawRequests',
        input: {},
        responsible: false,
      );
      final items =
          (requestsResult.output?['withdrawRequests'] as List? ?? []).cast<List<dynamic>>();
      return items
          // ignore cancelled withdraws
          .where((e) => !_cancelledWithdraw.contains(e[0] as String))
          .map((e) {
        return StEverWithdrawRequest(
          accountAddress: accountAddress,
          nonce: e[0] as String,
          data: StEverWithdrawRequestData.fromJson(e[1] as Map<String, dynamic>),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// How many stevers receive for evers
  /// Returns nano tokens
  Future<String> getDepositStEverAmount(String evers) async {
    final contractState = await getVaultContractState();
    final result = runLocal(
      accountStuffBoc: contractState.boc,
      contractAbi: stEverAbi,
      method: 'getDepositStEverAmount',
      input: {'_amount': evers},
      responsible: false,
    );
    final amount = result.output?.values.firstOrNull as String?;
    return amount ?? '0';
  }

  /// How many evers receive for stevers
  /// Returns nano tokens
  Future<String> getWithdrawEverAmount(String stEvers) async {
    final contractState = await getVaultContractState();
    final result = runLocal(
      accountStuffBoc: contractState.boc,
      contractAbi: stEverAbi,
      method: 'getWithdrawEverAmount',
      input: {'_amount': stEvers},
      responsible: false,
    );
    final amount = result.output?.values.firstOrNull as String?;
    return amount ?? '0';
  }

  Future<StEverDetails> getStEverDetails() async {
    final contractState = await getVaultContractState();
    final result = runLocal(
      accountStuffBoc: contractState.boc,
      contractAbi: stEverAbi,
      method: 'getDetails',
      input: {'answerId': 0},
      responsible: false,
    );
    final detailsJson = result.output?.values.firstOrNull as Map<String, dynamic>?;
    if (detailsJson == null) throw Exception('StEver details not provided');
    return StEverDetails.fromJson(detailsJson);
  }

  Future<FullContractState> getVaultContractState() async {
    final contractState = await transportSource.transport.getFullContractState(stEverVault);
    if (contractState == null) throw Exception('StEver contract state not provided');
    return contractState;
  }

  Future<FullContractState> getUserContractState(String accountVault) async {
    final contractState = await transportSource.transport.getFullContractState(accountVault);
    if (contractState == null) throw Exception('User StEver contract state not provided');
    return contractState;
  }

  /// Remember cancelled withdraw request and don't show it in [userAvailableWithdraw]
  void acceptCancelledWithdraw(StEverWithdrawRequest request) {
    _cancelledWithdraw.add(request.nonce);
  }
}
