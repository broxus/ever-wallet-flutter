import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_send_bloc.freezed.dart';

@injectable
class TonWalletSendBloc extends Bloc<TonWalletSendEvent, TonWalletSendState> {
  final NekotonService _nekotonService;

  TonWalletSendBloc(this._nekotonService) : super(TonWalletSendStateInitial());

  @override
  Stream<TonWalletSendState> mapEventToState(TonWalletSendEvent event) async* {
    try {
      if (event is _Send) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        await tonWallet.send(
          message: event.message,
          password: event.password,
        );

        yield TonWalletSendStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletSendStateError(err);
    }
  }
}

@freezed
class TonWalletSendEvent with _$TonWalletSendEvent {
  const factory TonWalletSendEvent.send({
    required String address,
    required UnsignedMessage message,
    required String password,
  }) = _Send;
}

abstract class TonWalletSendState {}

class TonWalletSendStateInitial extends TonWalletSendState {}

class TonWalletSendStateSuccess extends TonWalletSendState {}

class TonWalletSendStateError extends TonWalletSendState {
  final Exception exception;

  TonWalletSendStateError(this.exception);
}
