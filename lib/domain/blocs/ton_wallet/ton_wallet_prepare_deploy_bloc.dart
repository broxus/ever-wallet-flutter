import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_prepare_deploy_bloc.freezed.dart';

@injectable
class TonWalletPrepareDeployBloc extends Bloc<TonWalletPrepareDeployEvent, TonWalletPrepareDeployState> {
  final NekotonService _nekotonService;

  TonWalletPrepareDeployBloc(this._nekotonService) : super(TonWalletPrepareDeployStateInitial());

  @override
  Stream<TonWalletPrepareDeployState> mapEventToState(TonWalletPrepareDeployEvent event) async* {
    try {
      if (event is _PrepareDeploy) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        final message = await tonWallet.prepareDeploy(kDefaultMessageExpiration);

        yield TonWalletPrepareDeployStateSuccess(message);
      } else if (event is _PrepareDeployWithMultipleOwners) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        final message = await tonWallet.prepareDeployWithMultipleOwners(
          expiration: kDefaultMessageExpiration,
          custodians: event.custodians,
          reqConfirms: event.reqConfirms,
        );

        yield TonWalletPrepareDeployStateSuccess(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletPrepareDeployStateError(err);
    }
  }
}

@freezed
class TonWalletPrepareDeployEvent with _$TonWalletPrepareDeployEvent {
  const factory TonWalletPrepareDeployEvent.prepareDeploy(String address) = _PrepareDeploy;

  const factory TonWalletPrepareDeployEvent.prepareDeployWithMultipleOwners({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
  }) = _PrepareDeployWithMultipleOwners;
}

abstract class TonWalletPrepareDeployState {}

class TonWalletPrepareDeployStateInitial extends TonWalletPrepareDeployState {}

class TonWalletPrepareDeployStateSuccess extends TonWalletPrepareDeployState {
  final UnsignedMessage message;

  TonWalletPrepareDeployStateSuccess(this.message);
}

class TonWalletPrepareDeployStateError extends TonWalletPrepareDeployState {
  final Exception exception;

  TonWalletPrepareDeployStateError(this.exception);
}
