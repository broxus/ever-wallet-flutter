import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_prepare_deploy_bloc.freezed.dart';

@injectable
class TonWalletPrepareDeployBloc extends Bloc<TonWalletPrepareDeployEvent, TonWalletPrepareDeployState> {
  final NekotonService _nekotonService;

  TonWalletPrepareDeployBloc(this._nekotonService) : super(const TonWalletPrepareDeployState.initial());

  @override
  Stream<TonWalletPrepareDeployState> mapEventToState(TonWalletPrepareDeployEvent event) async* {
    try {
      if (event is _PrepareDeploy) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        final message = await tonWallet.prepareDeploy(kDefaultMessageExpiration);

        yield TonWalletPrepareDeployState.success(message);
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

        yield TonWalletPrepareDeployState.success(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletPrepareDeployState.error(err);
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

@freezed
class TonWalletPrepareDeployState with _$TonWalletPrepareDeployState {
  const factory TonWalletPrepareDeployState.initial() = _Initial;

  const factory TonWalletPrepareDeployState.success(UnsignedMessage message) = _Success;

  const factory TonWalletPrepareDeployState.error(Exception exception) = _Error;

  const TonWalletPrepareDeployState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
