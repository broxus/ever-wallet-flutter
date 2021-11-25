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

  TokenWalletSendBloc(this._nekotonService) : super(const TokenWalletSendState.initial());

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

        await Future.delayed(const Duration(seconds: 3));

        yield const TokenWalletSendState.success();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TokenWalletSendState.error(err);
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

@freezed
class TokenWalletSendState with _$TokenWalletSendState {
  const factory TokenWalletSendState.initial() = _Initial;

  const factory TokenWalletSendState.success() = _Success;

  const factory TokenWalletSendState.error(Exception exception) = _Error;

  const TokenWalletSendState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
