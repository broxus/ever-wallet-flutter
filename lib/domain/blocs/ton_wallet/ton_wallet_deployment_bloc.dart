import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../services/nekoton_service.dart';
import 'ton_wallet_deployment_fees_bloc.dart';

part 'ton_wallet_deployment_bloc.freezed.dart';

@injectable
class TonWalletDeploymentBloc extends Bloc<TonWalletDeploymentEvent, TonWalletDeploymentState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
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
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<TonWalletDeploymentState> mapEventToState(TonWalletDeploymentEvent event) async* {
    try {
      if (event is _PrepareDeploy) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        final contractState = await tonWallet.contractState;
        final balance = contractState.balance;
        yield TonWalletDeploymentState.initial(balance.toTokens());
        _message = await tonWallet.prepareDeploy(kDefaultMessageExpiration);
        feesBloc.add(TonWalletDeploymentFeesEvent.estimateFees(balance: balance, message: _message!));
      } else if (event is _Deploy) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        if (_message != null) {
          yield const TonWalletDeploymentState.sending();
          await tonWallet.send(
            message: _message!,
            password: event.password,
          );

          yield const TonWalletDeploymentState.success();
        }
      } else if (event is _GoToPassword) {
        yield const TonWalletDeploymentState.password();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
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
