import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../utils/error_message.dart';

part 'ton_wallet_deployment_fees_bloc.freezed.dart';

@injectable
class TonWalletDeploymentFeesBloc extends Bloc<TonWalletDeploymentFeesEvent, TonWalletDeploymentFeesState> {
  final TonWallet? _tonWallet;

  TonWalletDeploymentFeesBloc(@factoryParam this._tonWallet) : super(const TonWalletDeploymentFeesState.loading());

  @override
  Stream<TonWalletDeploymentFeesState> mapEventToState(TonWalletDeploymentFeesEvent event) async* {
    yield* event.when(
      estimateFees: (
        String balance,
        UnsignedMessage message,
      ) async* {
        try {
          yield const TonWalletDeploymentFeesState.loading();
          int feesValue;
          try {
            feesValue = await _tonWallet!.estimateFees(message);
          } catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletDeploymentFeesState.unknownContract(_tonWallet!.address);
            return;
          }
          final fees = feesValue.toString();
          final balanceValue = int.tryParse(balance) ?? 0;

          if (balanceValue > feesValue) {
            yield TonWalletDeploymentFeesState.ready(
              fees: fees.toTokens(),
            );
          } else {
            yield TonWalletDeploymentFeesState.insufficientFunds(
              fees: fees.toTokens(),
            );
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TonWalletDeploymentFeesState.error(err.getMessage());
        }
      },
    );
  }
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
