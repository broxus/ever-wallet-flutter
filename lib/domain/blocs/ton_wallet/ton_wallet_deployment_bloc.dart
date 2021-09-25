import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../constants/message_expiration.dart';
import '../../services/nekoton_service.dart';
import '../../utils/error_message.dart';
import 'ton_wallet_deployment_fees_bloc.dart';

part 'ton_wallet_deployment_bloc.freezed.dart';

@injectable
class TonWalletDeploymentBloc extends Bloc<TonWalletDeploymentEvent, TonWalletDeploymentState> {
  final NekotonService _nekotonService;
  final String? _address;
  UnsignedMessage? _message;
  late TonWalletDeploymentFeesBloc feesBloc;

  TonWalletDeploymentBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletDeploymentState.initial(null)) {
    feesBloc = getIt.get<TonWalletDeploymentFeesBloc>(param1: _address);
    add(const TonWalletDeploymentEvent.prepareDeploy());
  }

  @override
  Stream<TonWalletDeploymentState> mapEventToState(TonWalletDeploymentEvent event) async* {
    yield* event.when(
      prepareDeploy: () async* {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        try {
          final contractState = await tonWallet.contractState;
          final balance = contractState.balance;
          yield TonWalletDeploymentState.initial(balance.toTokens());
          _message = await tonWallet.prepareDeploy(defaultMessageExpiration);
          feesBloc.add(TonWalletDeploymentFeesEvent.estimateFees(balance: balance, message: _message!));
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TonWalletDeploymentState.error(err.getMessage());
        }
      },
      deploy: (String password) async* {
        try {
          final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

          if (_message != null) {
            yield const TonWalletDeploymentState.sending();
            await tonWallet.send(
              message: _message!,
              password: password,
            );

            yield const TonWalletDeploymentState.success();
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TonWalletDeploymentState.error(err.getMessage());
        }
      },
      goToPassword: () async* {
        yield const TonWalletDeploymentState.password();
      },
    );
  }
}

@freezed
class TonWalletDeploymentEvent with _$TonWalletDeploymentEvent {
  const factory TonWalletDeploymentEvent.prepareDeploy() = _PrepareDeploy;

  const factory TonWalletDeploymentEvent.deploy(String password) = _Deploy;

  const factory TonWalletDeploymentEvent.goToPassword() = _GoToPassword;
}

@freezed
class TonWalletDeploymentState with _$TonWalletDeploymentState {
  const factory TonWalletDeploymentState.initial(String? balance) = _Initial;

  const factory TonWalletDeploymentState.password() = _Password;

  const factory TonWalletDeploymentState.sending() = _Sending;

  const factory TonWalletDeploymentState.success() = _Success;

  const factory TonWalletDeploymentState.error(String info) = _Error;
}
