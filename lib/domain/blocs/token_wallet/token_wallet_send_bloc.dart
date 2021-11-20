import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_send_bloc.freezed.dart';

@injectable
class TokenWalletSendBloc extends Bloc<TokenWalletSendEvent, TokenWalletSendState> {
  final NekotonService _nekotonService;

  TokenWalletSendBloc(this._nekotonService) : super(TokenWalletSendStateInitial());

  @override
  Stream<TokenWalletSendState> mapEventToState(TokenWalletSendEvent event) async* {
    try {
      if (event is _Send) {
        final tokenWallet = _nekotonService.tokenWallets
            .firstWhereOrNull((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract);

        if (tokenWallet == null) {
          throw TokenWalletNotFoundException();
        }

        await tokenWallet.send(
          message: event.message,
          password: event.password,
        );

        yield TokenWalletSendStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TokenWalletSendStateError(err);
    }
  }
}

@freezed
class TokenWalletSendEvent with _$TokenWalletSendEvent {
  const factory TokenWalletSendEvent.send({
    required String owner,
    required String rootTokenContract,
    required UnsignedMessage message,
    required String password,
  }) = _Send;
}

abstract class TokenWalletSendState {}

class TokenWalletSendStateInitial extends TokenWalletSendState {}

class TokenWalletSendStateSuccess extends TokenWalletSendState {}

class TokenWalletSendStateError extends TokenWalletSendState {
  final Exception exception;

  TokenWalletSendStateError(this.exception);
}
