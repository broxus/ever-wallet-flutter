import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../constants/message_expiration.dart';

part 'token_wallet_deployment_bloc.freezed.dart';

@injectable
class TokenWalletDeploymentBloc extends Bloc<TokenWalletDeploymentEvent, TokenWalletDeploymentState> {
  final TokenWallet? _tokenWallet;
  UnsignedMessage? _message;

  TokenWalletDeploymentBloc(@factoryParam this._tokenWallet) : super(const TokenWalletDeploymentState.initial()) {
    add(const TokenWalletDeploymentEvent.prepareDeploy());
  }

  @override
  Stream<TokenWalletDeploymentState> mapEventToState(TokenWalletDeploymentEvent event) async* {
    yield* event.when(
      prepareDeploy: () async* {
        try {
          _message = await _tokenWallet!.prepareDeploy(defaultMessageExpiration);

          final feesValue = await _tokenWallet!.estimateFees(_message!);
          final fees = feesValue.toString();

          final contractState = await _tokenWallet!.ownerContractState;
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
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TokenWalletDeploymentState.error(err.toString());
        }
      },
      deploy: (String password) async* {
        if (_message != null) {
          yield const TokenWalletDeploymentState.sending();
          try {
            await _tokenWallet!.send(
              message: _message!,
              password: password,
            );

            yield const TokenWalletDeploymentState.success();
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TokenWalletDeploymentState.error(err.toString());
          }
        }
      },
      goToPassword: () async* {
        yield const TokenWalletDeploymentState.password();
      },
    );
  }
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
