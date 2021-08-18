import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../utils/error_message.dart';

part 'ton_wallet_fees_bloc.freezed.dart';

@injectable
class TonWalletFeesBloc extends Bloc<TonWalletFeesEvent, TonWalletFeesState> {
  final TonWallet? _tonWallet;

  TonWalletFeesBloc(@factoryParam this._tonWallet) : super(const TonWalletFeesState.loading());

  @override
  Stream<TonWalletFeesState> mapEventToState(TonWalletFeesEvent event) async* {
    yield* event.when(
      estimateFees: (
        int nanoAmount,
        UnsignedMessage message,
      ) async* {
        try {
          yield const TonWalletFeesState.loading();
          final feesValue = await _tonWallet!.estimateFees(message);
          final fees = feesValue.toString();

          final contractState = await _tonWallet!.contractState;
          final balance = contractState.balance;
          final balanceValue = int.parse(balance);

          if (balanceValue > (feesValue + nanoAmount)) {
            yield TonWalletFeesState.ready(
              fees: fees.toTokens(),
            );
          } else {
            yield TonWalletFeesState.insufficientFunds(
              fees: fees.toTokens(),
            );
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TonWalletFeesState.error(err.getMessage());
        }
      },
    );
  }
}

@freezed
class TonWalletFeesEvent with _$TonWalletFeesEvent {
  const factory TonWalletFeesEvent.estimateFees({
    required int nanoAmount,
    required UnsignedMessage message,
  }) = _EstimateFees;
}

@freezed
class TonWalletFeesState with _$TonWalletFeesState {
  const factory TonWalletFeesState.loading() = _loading;

  const factory TonWalletFeesState.ready({
    required String fees,
  }) = _MessagePrepared;

  const factory TonWalletFeesState.insufficientFunds({
    required String fees,
  }) = _InsufficientFunds;

  const factory TonWalletFeesState.error(String info) = _Error;
}
