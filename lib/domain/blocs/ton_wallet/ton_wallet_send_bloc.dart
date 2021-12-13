import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_send_bloc.freezed.dart';

@injectable
class TonWalletSendBloc extends Bloc<TonWalletSendEvent, TonWalletSendState> {
  final NekotonService _nekotonService;

  TonWalletSendBloc(this._nekotonService) : super(const TonWalletSendState.initial());

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

        yield const TonWalletSendState.success();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletSendState.error(err);
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

@freezed
class TonWalletSendState with _$TonWalletSendState {
  const factory TonWalletSendState.initial() = _Initial;

  const factory TonWalletSendState.success() = _Success;

  const factory TonWalletSendState.error(Exception exception) = _Error;

  const TonWalletSendState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
