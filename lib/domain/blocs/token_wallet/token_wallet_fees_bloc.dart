import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';
import '../../utils/error_message.dart';

part 'token_wallet_fees_bloc.freezed.dart';

@injectable
class TokenWalletFeesBloc extends Bloc<TokenWalletFeesEvent, TokenWalletFeesState> {
  final NekotonService _nekotonService;
  final String? _owner;
  final String? _rootTokenContract;

  TokenWalletFeesBloc(
    this._nekotonService,
    @factoryParam this._owner,
    @factoryParam this._rootTokenContract,
  ) : super(const TokenWalletFeesState.loading());

  @override
  Stream<TokenWalletFeesState> mapEventToState(TokenWalletFeesEvent event) async* {
    yield* event.when(
      estimateFees: (
        String nanoTokens,
        UnsignedMessage message,
      ) async* {
        try {
          final tokenWallet = _nekotonService.tokenWallets
              .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

          yield const TokenWalletFeesState.loading();
          final feesValue = await tokenWallet.estimateFees(message);
          final fees = feesValue.toString();

          final ownerContractState = await tokenWallet.ownerContractState;
          final ownerBalance = ownerContractState.balance;
          final ownerBalanceValue = int.parse(ownerBalance);

          final balance = await tokenWallet.balance;
          final balanceValue = BigInt.parse(balance);

          final tokensValue = BigInt.parse(nanoTokens);

          final isPossibleToSendMessage = ownerBalanceValue > feesValue;
          final isPossibleToSendTokens = balanceValue >= tokensValue;

          if (isPossibleToSendMessage && isPossibleToSendTokens) {
            yield TokenWalletFeesState.ready(
              fees: fees.toTokens(),
            );
          } else if (!isPossibleToSendMessage) {
            yield TokenWalletFeesState.insufficientOwnerFunds(
              fees: fees.toTokens(),
            );
          } else {
            yield TokenWalletFeesState.insufficientFunds(
              fees: fees.toTokens(),
            );
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TokenWalletFeesState.error(err.getMessage());
        }
      },
    );
  }
}

@freezed
class TokenWalletFeesEvent with _$TokenWalletFeesEvent {
  const factory TokenWalletFeesEvent.estimateFees({
    required String nanoTokens,
    required UnsignedMessage message,
  }) = _EstimateFees;
}

@freezed
class TokenWalletFeesState with _$TokenWalletFeesState {
  const factory TokenWalletFeesState.loading() = _loading;

  const factory TokenWalletFeesState.ready({
    required String fees,
  }) = _MessagePrepared;

  const factory TokenWalletFeesState.insufficientFunds({
    required String fees,
  }) = _InsufficientFunds;

  const factory TokenWalletFeesState.insufficientOwnerFunds({
    required String fees,
  }) = _InsufficientOwnerFunds;

  const factory TokenWalletFeesState.error(String info) = _Error;
}
