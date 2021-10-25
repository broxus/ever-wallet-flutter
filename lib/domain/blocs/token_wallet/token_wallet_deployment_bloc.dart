import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_deployment_bloc.freezed.dart';

@injectable
class TokenWalletDeploymentBloc extends Bloc<TokenWalletDeploymentEvent, TokenWalletDeploymentState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
  final String? _owner;
  final String? _rootTokenContract;
  UnsignedMessage? _message;

  TokenWalletDeploymentBloc(
    this._nekotonService,
    @factoryParam this._owner,
    @factoryParam this._rootTokenContract,
  ) : super(const TokenWalletDeploymentState.initial()) {
    add(const TokenWalletDeploymentEvent.prepareDeploy());
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<TokenWalletDeploymentState> mapEventToState(TokenWalletDeploymentEvent event) async* {
    try {
      if (event is _PrepareDeploy) {
        final tokenWallet = _nekotonService.tokenWallets
            .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

        _message = await tokenWallet.prepareDeploy(kDefaultMessageExpiration);

        final feesValue = await tokenWallet.estimateFees(_message!);
        final fees = feesValue.toString();

        final contractState = await tokenWallet.ownerContractState;
        final balance = contractState.balance;
        final balanceValue = int.parse(balance);

        if (balanceValue > feesValue) {
          yield TokenWalletDeploymentState.messagePrepared(
            balance: balance.toTokens(),
            fees: fees.toTokens(),
          );
        } else {
          yield TokenWalletDeploymentState.insufficientFunds(
            balance: balance.toTokens(),
            fees: fees.toTokens(),
          );
        }
      } else if (event is _Deploy) {
        final tokenWallet = _nekotonService.tokenWallets
            .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

        if (_message != null) {
          yield const TokenWalletDeploymentState.sending();
          await tokenWallet.send(
            message: _message!,
            password: event.password,
          );

          yield const TokenWalletDeploymentState.success();
        }
      } else if (event is _GoToPassword) {
        yield const TokenWalletDeploymentState.password();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class TokenWalletDeploymentEvent with _$TokenWalletDeploymentEvent {
  const factory TokenWalletDeploymentEvent.prepareDeploy() = _PrepareDeploy;

  const factory TokenWalletDeploymentEvent.deploy(String password) = _Deploy;

  const factory TokenWalletDeploymentEvent.goToPassword() = _GoToPassword;
}

@freezed
class TokenWalletDeploymentState with _$TokenWalletDeploymentState {
  const factory TokenWalletDeploymentState.initial() = _Initial;

  const factory TokenWalletDeploymentState.messagePrepared({
    required String balance,
    required String fees,
  }) = _MessagePrepared;

  const factory TokenWalletDeploymentState.insufficientFunds({
    required String balance,
    required String fees,
  }) = _InsufficientFunds;

  const factory TokenWalletDeploymentState.password() = _Password;

  const factory TokenWalletDeploymentState.sending() = _Sending;

  const factory TokenWalletDeploymentState.success() = _Success;

  const factory TokenWalletDeploymentState.error(String info) = _Error;
}
