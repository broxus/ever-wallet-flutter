import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/subjects.dart';

import '../../services/nekoton_service.dart';

part 'ton_wallet_info_bloc.freezed.dart';

@injectable
class TonWalletInfoBloc extends Bloc<_Event, TonWalletInfoState?> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onStateChangedSubscription;

  TonWalletInfoBloc(this._nekotonService) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _onStateChangedSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TonWalletInfoState?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        _streamSubscription?.cancel();
        _onStateChangedSubscription?.cancel();
        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == event.address)
            .listen((tonWalletEvent) {
          _onStateChangedSubscription?.cancel();
          _onStateChangedSubscription = tonWalletEvent.onStateChangedStream.listen((event) => add(_LocalEvent.update(
                tonWallet: tonWalletEvent,
                contractState: event,
              )));
        });
      } else if (event is _Update) {
        final contractState = event.contractState.copyWith(balance: event.contractState.balance.toTokens());

        yield TonWalletInfoState(
          address: event.tonWallet.address,
          contractState: contractState,
          walletType: event.tonWallet.walletType,
          details: event.tonWallet.details,
          publicKey: event.tonWallet.publicKey,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update({
    required TonWallet tonWallet,
    required ContractState contractState,
  }) = _Update;
}

@freezed
class TonWalletInfoEvent extends _Event with _$TonWalletInfoEvent {
  const factory TonWalletInfoEvent.load(String address) = _Load;
}

@freezed
class TonWalletInfoState with _$TonWalletInfoState {
  const factory TonWalletInfoState({
    required String address,
    required ContractState contractState,
    required WalletType walletType,
    required TonWalletDetails details,
    required String publicKey,
  }) = _TonWalletInfoState;
}
