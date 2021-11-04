import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_fees_bloc.freezed.dart';

@injectable
class TonWalletFeesBloc extends Bloc<TonWalletFeesEvent, TonWalletFeesState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  final String? _address;

  TonWalletFeesBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletFeesState.loading());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<TonWalletFeesState> mapEventToState(TonWalletFeesEvent event) async* {
    try {
      if (event is _EstimateFees) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        yield const TonWalletFeesState.loading();
        final feesValue = await tonWallet.estimateFees(event.message);
        final fees = feesValue.toString();

        final contractState = await tonWallet.contractState;
        final balance = contractState.balance;
        final balanceValue = int.parse(balance);

        if (balanceValue > (feesValue + event.nanoAmount)) {
          yield TonWalletFeesState.ready(
            fees: fees.toTokens(),
          );
        } else {
          yield TonWalletFeesState.insufficientFunds(
            fees: fees.toTokens(),
          );
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
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
