import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_expired_transactions_bloc.freezed.dart';

@injectable
class TonWalletExpiredTransactionsBloc extends Bloc<_Event, List<PendingTransaction>> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onMessageExpiredSubscription;

  TonWalletExpiredTransactionsBloc(this._nekotonService) : super(const []);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onMessageExpiredSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<List<PendingTransaction>> mapEventToState(_Event event) async* {
    // yield [
    //   PendingTransaction(
    //     messageHash: '0xDEAFBEAF',
    //     bodyHash: '0xDEAFBEAF',
    //     src: '0:9c1811c276eec34c6d690cfacf8ceb8f4beb50bb5df73c2b1b2be633c03a19cc',
    //     expireAt: (DateTime.now().millisecondsSinceEpoch + 100000000) ~/ 1000,
    //   ),
    // ];

    // return;

    try {
      if (event is _Load) {
        yield const [];

        final address = event.address;

        _streamSubscription?.cancel();
        _onMessageExpiredSubscription?.cancel();

        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == address)
            .distinct()
            .listen((event) {
          final tonWallet = event;

          _onMessageExpiredSubscription?.cancel();

          _onMessageExpiredSubscription = tonWallet.onMessageExpiredStream.listen(
            (event) => add(
              _LocalEvent.update(event),
            ),
          );
        });
      } else if (event is _Update) {
        yield event.transactions;
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
  const factory _LocalEvent.update(List<PendingTransaction> transactions) = _Update;
}

@freezed
class TonWalletExpiredTransactionsEvent extends _Event with _$TonWalletExpiredTransactionsEvent {
  const factory TonWalletExpiredTransactionsEvent.load(String address) = _Load;
}
