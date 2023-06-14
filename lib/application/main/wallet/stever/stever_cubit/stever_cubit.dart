import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/send_info_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_send_transaction_flow/token_send_info_page.dart';
import 'package:ever_wallet/application/main/wallet/stever/stever_result_screen.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/stever/stever_withdraw_request.dart';
import 'package:ever_wallet/data/repositories/stever_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:string_extensions/string_extensions.dart';

part 'stever_cubit.freezed.dart';

/// [inProgress] is optional and must be handled in ui base on requests list of state
enum StakeType { stake, unstake, inProgress }

typedef CurrencyLoader = Future<Currency?> Function(String rootContract);

/// Basic class to stake/unstake ever from account
class StEverCubit extends Cubit<StEverCubitState> {
  final StEverRepository stEverRepository;
  final TokenWalletsRepository tokenWalletsRepository;
  final TonWalletsRepository tonWalletsRepository;
  final CurrencyLoader currencyLoader;
  final NavigatorState navigator;

  final String accountAddress;
  final inputController = TextEditingController();

  StakeType _localType = StakeType.stake;

  /// Additional that that is loaded once at the beginning and used to calculate prices and balances
  TonWallet? _everWallet;
  Currency? _everWalletCurrency;

  TokenWallet? _stEverWallet;
  Currency? _stEverWalletCurrency;
  double? exchangeRate;
  List<StEverWithdrawRequest>? _requests;
  StreamSubscription? _requestsSub;

  /// Public key that is related to [accountAddress]
  String accountPublicKey = '';

  String apy = '0';

  StEverCubit({
    required this.stEverRepository,
    required this.accountAddress,
    required this.tokenWalletsRepository,
    required this.tonWalletsRepository,
    required this.currencyLoader,
    required this.navigator,
  }) : super(
          const StEverCubitState(enteredValue: '', type: StakeType.stake, canPressButton: false),
        ) {
    inputController.addListener(() => _updateValue(inputController.text));
    _getTokensAndCurrencies();
  }

  @override
  Future<void> close() {
    inputController.dispose();
    _requestsSub?.cancel();
    return super.close();
  }

  Future<void> _getTokensAndCurrencies() async {
    try {
      _everWallet = await tonWalletsRepository.getTonWalletStream(accountAddress).first;
      await tokenWalletsRepository.updateSubscriptionIfAbsent(
        owner: accountAddress,
        rootTokenContract: stEverRootContract,
      );
      _stEverWallet = await tokenWalletsRepository
          .tokenWalletStream(owner: accountAddress, rootTokenContract: stEverRootContract)
          .first;

      _stEverWalletCurrency = await currencyLoader(stEverRootContract);
      _everWalletCurrency = await currencyLoader(kAddressForEverCurrency);
      final loadedApy = await stEverRepository.getAverageAPY();
      apy = (loadedApy * 100).toStringAsFixed(2);
      final details = await stEverRepository.getStEverDetails();
      exchangeRate = double.parse(details.totalAssets) / double.parse(details.stEverSupply);
      accountPublicKey =
          (await tonWalletsRepository.localCustodiansStream(accountAddress).first)?.first ?? '';

      /// Do it last because if user don't have address, then method can throw error
      _requestsSub = stEverRepository.withdrawRequestsStream(accountAddress).listen((requests) {
        _requests = requests;
        if (requests.isEmpty && state.type == StakeType.inProgress) {
          /// avoid ui lag
          emit(state.copyWith(requests: requests, type: StakeType.stake));
        } else {
          emit(state.copyWith(requests: requests));
        }
      });
    } catch (e, t) {
      logger.e('StEver init', e, t);
    }

    // trigger updating of balances
    _updateValue(inputController.text);
  }

  Future<void> _updateValue(String v) async {
    final value = _getPureAmount(v);
    emit(stateWithData(value: value));

    String? receiveAmount;
    try {
      if (value.isNotEmpty && double.tryParse(value) != null) {
        switch (_localType) {
          case StakeType.stake:
            receiveAmount = await stEverRepository.getDepositStEverAmount(value.toNanoTokens());
            break;
          case StakeType.unstake:
            receiveAmount = await stEverRepository.getWithdrawEverAmount(value.toNanoTokens());
            break;
          case StakeType.inProgress:
            // do nothing
            break;
        }
      }
    } catch (e, t) {
      logger.e('Loading data after updating value', e, t);
    }

    emit(stateWithData(value: value, receiveAmount: receiveAmount));
  }

  StEverCubitState stateWithData({required String value, String? receiveAmount}) {
    String? balance;
    String? enteredPrice;
    String attachedAmount;

    switch (_localType) {
      case StakeType.stake:
        attachedAmount = stakeDepositAttachedFee.toTokensFull();
        balance = _everWallet?.contractState.balance.toTokensFull();
        if (_everWalletCurrency != null) {
          enteredPrice = _zeroOrValue(value)
              .toNanoTokens()
              .balanceAsPrice(_everWalletCurrency!.price, _decimalsLength(value));
        }
        break;
      case StakeType.unstake:
        attachedAmount = stakeWithdrawAttachedFee.toTokensFull();
        balance = _stEverWallet?.balance.toTokensFull();
        if (_stEverWalletCurrency != null) {
          enteredPrice = _zeroOrValue(value)
              .toNanoTokens()
              .balanceAsPrice(_stEverWalletCurrency!.price, _decimalsLength(value));
        }
        break;
      case StakeType.inProgress:
        attachedAmount = '0';
        break;
    }
    final canPress =
        double.parse(_zeroOrValue(value)) <= double.parse(_getPureAmount(balance ?? '0.0')) &&
            double.parse(_zeroOrValue(value)) != 0.0;

    return StEverCubitState(
      type: _localType,
      enteredValue: value,
      balance: balance,
      enteredPrice: enteredPrice,
      attachedAmount: attachedAmount,
      exchangeRate: exchangeRate,
      requests: _requests,
      receive: receiveAmount?.toTokensFull(),
      canPressButton: canPress,
      apy: apy,
    );
  }

  int _decimalsLength(String value) {
    final parsed = double.parse(_zeroOrValue(value));
    if (parsed < 10) return 4;
    if (parsed < 1000) return 3;
    if (parsed < 100000) return 1;
    return 0;
  }

  String _zeroOrValue(String value) => value.isEmpty ? '0' : value;

  Future<void> changeTab(StakeType type) async {
    if (type == _localType) return;

    _localType = type;
    inputController.text = '';
    return _updateValue('');
  }

  void selectMax() {
    final max = state.balance ?? '0.0';
    inputController.text = _getPureAmount(max);
  }

  /// To delimit integer part and float part, DOT is used, comma just to separate thousands
  String _getPureAmount([String? value]) {
    final delimitersReg = RegExp(r'(,|\.)');
    final amount = value ?? inputController.text;
    if (delimitersReg.allMatches(amount).length > 1) {
      /// Try to remove all comma's and save delimiter dot
      final lastDecimalDelimiter = amount.lastIndexOf(delimitersReg);
      return amount
          .replaceAtIndex(index: lastDecimalDelimiter, replacement: '|')!
          .replaceAll(delimitersReg, '')
          .replaceAll('|', '.');
    } else {
      /// only one delimiter, just avoid comma
      return amount.replaceAll(',', '');
    }
  }

  Future<void> doAction() async {
    emit(state.copyWith(isLoading: true));

    switch (_localType) {
      case StakeType.stake:
        final message = stEverRepository.depositEver(
          accountAddress: accountAddress,
          depositAmount: _getPureAmount().toNanoTokens(),
        );
        final body = encodeInternalInput(
          contractAbi: message.payload!.abi,
          method: message.payload!.method,
          input: message.payload!.params,
        );

        final success = await showPlatformModalBottomSheet<bool>(
          context: navigator.context,
          builder: (context) => Navigator(
            initialRoute: '/',
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => SendInfoPage(
                modalContext: context,
                address: message.sender,
                publicKey: accountPublicKey,
                destination: repackAddress(message.recipient),
                amount: message.amount,
                comment: body,
                resultBuilder: (modalContext) => StEverResultScreen(
                  title: context.localization.staking_progress,
                  subtitle: context.localization.stever_apper_in_minutes,
                  modalContext: modalContext,
                ),
              ),
            ),
          ),
        );
        if (success ?? false) {
          navigator.pop();
        }

        break;
      case StakeType.unstake:
        final withdrawAmount = _getPureAmount().toNanoTokens();
        final withdrawPayload = await stEverRepository.withdrawStEver(
          accountAddress: accountAddress,
        );
        final success = await showPlatformModalBottomSheet<bool>(
          context: navigator.context,
          builder: (context) => Navigator(
            initialRoute: '/',
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => TokenSendInfoPage(
                modalContext: context,
                owner: accountAddress,
                rootTokenContract: stEverRootContract,
                publicKey: accountPublicKey,
                destination: stEverVault,
                amount: withdrawAmount,
                notifyReceiver: true,
                comment: withdrawPayload,
                attachedAmount: stakeWithdrawAttachedFee,
                resultBuilder: (modalContext) => StEverResultScreen(
                  title: context.localization.unstaking_progress,
                  subtitle: context.localization.withdraw_72_hours_progress,
                  modalContext: modalContext,
                ),
              ),
            ),
          ),
        );
        if (success ?? false) {
          navigator.pop();
        }
        break;
      case StakeType.inProgress:
        // do nothing
        break;
    }

    emit(state.copyWith(isLoading: false));
  }
}

@freezed
class StEverCubitState with _$StEverCubitState {
  const factory StEverCubitState({
    required String enteredValue,
    required StakeType type,
    bool? isLoading,
    String? enteredPrice,
    String? balance,
    double? exchangeRate,
    String? attachedAmount,
    String? receive,
    String? apy,
    List<StEverWithdrawRequest>? requests,
    bool? canPressButton,
  }) = _StState;
}
