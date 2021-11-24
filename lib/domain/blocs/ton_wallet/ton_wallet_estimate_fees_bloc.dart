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

  TonWalletEstimateFeesBloc(this._nekotonService) : super(const TonWalletEstimateFeesState.initial());

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
          yield TonWalletEstimateFeesState.success(fees);
        } else {
          yield TonWalletEstimateFeesState.insufficientFunds(fees);
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletEstimateFeesState.error(err);
    }
  }
}

@freezed
class TonWalletEstimateFeesEvent with _$TonWalletEstimateFeesEvent {
  const factory TonWalletEstimateFeesEvent.estimateFees({
    required String address,
    required UnsignedMessage message,
    @Default('0') String amount,
  }) = _EstimateFees;
}

@freezed
class TonWalletEstimateFeesState with _$TonWalletEstimateFeesState {
  const factory TonWalletEstimateFeesState.initial() = _Initial;

  const factory TonWalletEstimateFeesState.success(String fees) = _Success;

  const factory TonWalletEstimateFeesState.insufficientFunds(String fees) = _InsufficientFunds;

  const factory TonWalletEstimateFeesState.error(Exception exception) = _Error;

  const TonWalletEstimateFeesState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
