import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_fees_bloc.freezed.dart';

@injectable
class TokenWalletFeesBloc extends Bloc<TokenWalletFeesEvent, TokenWalletFeesState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  final String? _owner;
  final String? _rootTokenContract;

  TokenWalletFeesBloc(
    this._nekotonService,
    @factoryParam this._owner,
    @factoryParam this._rootTokenContract,
  ) : super(const TokenWalletFeesState.loading());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<TokenWalletFeesState> mapEventToState(TokenWalletFeesEvent event) async* {
    try {
      if (event is _EstimateFees) {
        final tokenWallet = _nekotonService.tokenWallets
            .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

        yield const TokenWalletFeesState.loading();
        final feesValue = await tokenWallet.estimateFees(event.message);
        final fees = feesValue.toString();

        final ownerContractState = await tokenWallet.ownerContractState;
        final ownerBalance = ownerContractState.balance;
        final ownerBalanceValue = int.parse(ownerBalance);

        final balance = await tokenWallet.balance;
        final balanceValue = BigInt.parse(balance);

        final tokensValue = BigInt.parse(event.nanoTokens);

        final isPossibleToSendMessage = ownerBalanceValue > feesValue;
        final isPossibleToSendTokens = balanceValue >= tokensValue && tokensValue != BigInt.zero;

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
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TokenWalletFeesState.error(err.toString());
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
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
