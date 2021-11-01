import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/domain/models/ton_wallet_info.dart';
import 'package:crystal/domain/repositories/ton_wallet_info_repository.dart';
import 'package:crystal/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/subjects.dart';

import '../../services/nekoton_service.dart';

part 'ton_wallet_info_bloc.freezed.dart';

@injectable
class TonWalletInfoBloc extends Bloc<_Event, TonWalletInfo?> {
  final NekotonService _nekotonService;
  final TonWalletInfoRepository _tonWalletInfoRepository;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onStateChangedSubscription;

  TonWalletInfoBloc(
    this._nekotonService,
    this._tonWalletInfoRepository,
  ) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onStateChangedSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TonWalletInfo?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        final tonWalletInfo = _tonWalletInfoRepository.get(event.address);

        if (tonWalletInfo != null) {
          add(_LocalEvent.update(tonWalletInfo));
        }

        _streamSubscription?.cancel();
        _onStateChangedSubscription?.cancel();
        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == event.address)
            .distinct()
            .listen((tonWalletEvent) async {
          _onStateChangedSubscription?.cancel();
          _onStateChangedSubscription =
              tonWalletEvent.onStateChangedStream.listen((event) => add(_LocalEvent.update(TonWalletInfo(
                    address: tonWalletEvent.address,
                    contractState: event.copyWith(balance: event.balance.toTokens()),
                    walletType: tonWalletEvent.walletType,
                    details: tonWalletEvent.details,
                    publicKey: tonWalletEvent.publicKey,
                  ))));

          final contractState = await tonWalletEvent.contractState;

          add(_LocalEvent.update(TonWalletInfo(
            address: tonWalletEvent.address,
            contractState: contractState.copyWith(balance: contractState.balance.toTokens()),
            walletType: tonWalletEvent.walletType,
            details: tonWalletEvent.details,
            publicKey: tonWalletEvent.publicKey,
          )));
        });
      } else if (event is _Update) {
        yield event.tonWalletInfo;

        await _tonWalletInfoRepository.save(event.tonWalletInfo);
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
  const factory _LocalEvent.update(TonWalletInfo tonWalletInfo) = _Update;
}

@freezed
class TonWalletInfoEvent extends _Event with _$TonWalletInfoEvent {
  const factory TonWalletInfoEvent.load(String address) = _Load;
}
