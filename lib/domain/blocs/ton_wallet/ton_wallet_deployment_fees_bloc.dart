import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';
import '../../utils/error_message.dart';

part 'ton_wallet_deployment_fees_bloc.freezed.dart';

@injectable
class TonWalletDeploymentFeesBloc extends Bloc<TonWalletDeploymentFeesEvent, TonWalletDeploymentFeesState> {
  final NekotonService _nekotonService;
  final String? _address;

  TonWalletDeploymentFeesBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletDeploymentFeesState.loading());

  @override
  Stream<TonWalletDeploymentFeesState> mapEventToState(TonWalletDeploymentFeesEvent event) async* {
    yield* event.when(
      estimateFees: (
        String balance,
        UnsignedMessage message,
      ) async* {
        try {
          final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

          yield const TonWalletDeploymentFeesState.loading();
          int feesValue;
          try {
            feesValue = await tonWallet.estimateFees(message);
          } catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletDeploymentFeesState.unknownContract(tonWallet.address);
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
