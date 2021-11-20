import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../../../logger.dart';
import '../../models/ton_wallet_info.dart';
import '../../repositories/ton_wallet_info_repository.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_info_bloc.freezed.dart';

@injectable
class TonWalletInfoBloc extends Bloc<_Event, TonWalletInfo?> {
  final NekotonService _nekotonService;
  final TonWalletInfoRepository _tonWalletInfoRepository;
  final _errorsSubject = PublishSubject<Exception>();
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
        yield null;

        final address = event.address;

        final tonWalletInfo = _tonWalletInfoRepository.get(address);

        if (tonWalletInfo != null) {
          add(_LocalEvent.update(tonWalletInfo));
        }

        _streamSubscription?.cancel();
        _onStateChangedSubscription?.cancel();

        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == address)
            .distinct()
            .listen((event) async {
          final tonWallet = event;

          _onStateChangedSubscription?.cancel();

          _onStateChangedSubscription = tonWallet.onStateChangedStream.listen((event) {
            final tonWalletInfo = TonWalletInfo(
              workchain: tonWallet.workchain,
              address: tonWallet.address,
              publicKey: tonWallet.publicKey,
              walletType: tonWallet.walletType,
              contractState: event,
              details: tonWallet.details,
              custodians: tonWallet.custodians,
            );

            add(_LocalEvent.update(tonWalletInfo));
          });

          final tonWalletInfo = TonWalletInfo(
            workchain: tonWallet.workchain,
            address: tonWallet.address,
            publicKey: tonWallet.publicKey,
            walletType: tonWallet.walletType,
            contractState: await tonWallet.contractState,
            details: tonWallet.details,
            custodians: tonWallet.custodians,
          );

          add(_LocalEvent.update(tonWalletInfo));
        });
      } else if (event is _Update) {
        yield event.tonWalletInfo;

        await _tonWalletInfoRepository.save(event.tonWalletInfo);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
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
