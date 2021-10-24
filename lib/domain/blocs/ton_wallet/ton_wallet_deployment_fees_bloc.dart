import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_deployment_fees_bloc.freezed.dart';

@injectable
class TonWalletDeploymentFeesBloc extends Bloc<TonWalletDeploymentFeesEvent, TonWalletDeploymentFeesState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
  final String? _address;

  TonWalletDeploymentFeesBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletDeploymentFeesState.loading());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<TonWalletDeploymentFeesState> mapEventToState(TonWalletDeploymentFeesEvent event) async* {
    try {
      if (event is _EstimateFees) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        yield const TonWalletDeploymentFeesState.loading();
        int feesValue;
        try {
          feesValue = await tonWallet.estimateFees(event.message);
        } catch (err, st) {
          logger.e(err, err, st);
          yield TonWalletDeploymentFeesState.unknownContract(tonWallet.address);
          return;
        }
        final fees = feesValue.toString();
        final balanceValue = int.tryParse(event.balance) ?? 0;

        if (balanceValue > feesValue) {
          yield TonWalletDeploymentFeesState.ready(
            fees: fees.toTokens(),
          );
        } else {
          yield TonWalletDeploymentFeesState.insufficientFunds(
            fees: fees.toTokens(),
          );
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class TonWalletDeploymentFeesEvent with _$TonWalletDeploymentFeesEvent {
  const factory TonWalletDeploymentFeesEvent.estimateFees({
    required String balance,
    required UnsignedMessage message,
  }) = _EstimateFees;
}

@freezed
class TonWalletDeploymentFeesState with _$TonWalletDeploymentFeesState {
  const factory TonWalletDeploymentFeesState.loading() = _loading;

  const factory TonWalletDeploymentFeesState.ready({
    required String fees,
  }) = _MessagePrepared;

  const factory TonWalletDeploymentFeesState.insufficientFunds({
    required String fees,
  }) = _InsufficientFunds;

  const factory TonWalletDeploymentFeesState.error(String info) = _Error;

  const factory TonWalletDeploymentFeesState.unknownContract(String address) = _UnknownContract;
}
