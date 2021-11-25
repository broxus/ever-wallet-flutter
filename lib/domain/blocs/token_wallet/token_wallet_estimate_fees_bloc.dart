import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_estimate_fees_bloc.freezed.dart';

@injectable
class TokenWalletEstimateFeesBloc extends Bloc<TokenWalletEstimateFeesEvent, TokenWalletEstimateFeesState> {
  final NekotonService _nekotonService;

  TokenWalletEstimateFeesBloc(this._nekotonService) : super(const TokenWalletEstimateFeesState.initial());

  @override
  Stream<TokenWalletEstimateFeesState> mapEventToState(TokenWalletEstimateFeesEvent event) async* {
    try {
      if (event is _EstimateFees) {
        final tokenWallet = _nekotonService.tokenWallets
            .firstWhereOrNull((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract);

        if (tokenWallet == null) {
          throw TokenWalletNotFoundException();
        }

        final feesValue = await tokenWallet.estimateFees(event.message);
        final fees = feesValue.toString();

        final ownerBalance = await tokenWallet.ownerContractState.then((value) => value.balance);
        final ownerBalanceValue = int.parse(ownerBalance);

        final balance = await tokenWallet.balance;
        final balanceValue = BigInt.parse(balance);

        final amountValue = BigInt.parse(event.amount);

        final isPossibleToSendMessage = ownerBalanceValue > feesValue;
        final isPossibleToSendTokens = balanceValue >= amountValue;

        if (isPossibleToSendMessage && isPossibleToSendTokens) {
          yield TokenWalletEstimateFeesState.success(fees);
        } else if (!isPossibleToSendMessage) {
          yield TokenWalletEstimateFeesState.insufficientOwnerFunds(fees);
        } else {
          yield TokenWalletEstimateFeesState.insufficientFunds(fees);
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TokenWalletEstimateFeesState.error(err);
    }
  }
}

@freezed
class TokenWalletEstimateFeesEvent with _$TokenWalletEstimateFeesEvent {
  const factory TokenWalletEstimateFeesEvent.estimateFees({
    required String owner,
    required String rootTokenContract,
    required UnsignedMessage message,
    @Default('0') String amount,
  }) = _EstimateFees;
}

@freezed
class TokenWalletEstimateFeesState with _$TokenWalletEstimateFeesState {
  const factory TokenWalletEstimateFeesState.initial() = _Initial;

  const factory TokenWalletEstimateFeesState.success(String fees) = _Success;

  const factory TokenWalletEstimateFeesState.insufficientFunds(String fees) = _InsufficientFunds;

  const factory TokenWalletEstimateFeesState.insufficientOwnerFunds(String fees) = _InsufficientOwnerFunds;

  const factory TokenWalletEstimateFeesState.error(Exception exception) = _Error;

  const TokenWalletEstimateFeesState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
