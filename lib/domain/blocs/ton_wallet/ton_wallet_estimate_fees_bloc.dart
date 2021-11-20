import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_estimate_fees_bloc.freezed.dart';

@injectable
class TonWalletEstimateFeesBloc extends Bloc<TonWalletEstimateFeesEvent, TonWalletEstimateFeesState> {
  final NekotonService _nekotonService;

  TonWalletEstimateFeesBloc(this._nekotonService) : super(TonWalletEstimateFeesStateInitial());

  @override
  Stream<TonWalletEstimateFeesState> mapEventToState(TonWalletEstimateFeesEvent event) async* {
    try {
      if (event is _EstimateFees) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        final feesValue = await tonWallet.estimateFees(event.message);
        final fees = feesValue.toString();

        final balance = await tonWallet.contractState.then((value) => value.balance);
        final balanceValue = int.parse(balance);

        final amountValue = int.parse(event.amount.fromTokens());

        final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

        if (isPossibleToSendMessage) {
          yield TonWalletEstimateFeesStateSuccess(fees);
        } else {
          yield TonWalletEstimateFeesStateSuccess.insufficientFunds(fees);
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletEstimateFeesStateError(err);
    }
  }
}

@freezed
class TonWalletEstimateFeesEvent with _$TonWalletEstimateFeesEvent {
  const factory TonWalletEstimateFeesEvent.estimateFees({
    required String address,
    required String amount,
    required UnsignedMessage message,
  }) = _EstimateFees;
}

abstract class TonWalletEstimateFeesState {}

class TonWalletEstimateFeesStateInitial extends TonWalletEstimateFeesState {}

@freezed
class TonWalletEstimateFeesStateSuccess extends TonWalletEstimateFeesState with _$TonWalletEstimateFeesStateSuccess {
  const factory TonWalletEstimateFeesStateSuccess(String fees) = _TonWalletEstimateFeesStateSuccess;

  const factory TonWalletEstimateFeesStateSuccess.insufficientFunds(String fees) =
      _TonWalletEstimateFeesStateSuccessInsufficientFunds;
}

class TonWalletEstimateFeesStateError extends TonWalletEstimateFeesState {
  final Exception exception;

  TonWalletEstimateFeesStateError(this.exception);
}
