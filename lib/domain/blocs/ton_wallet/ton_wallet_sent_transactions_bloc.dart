import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_sent_transactions_bloc.freezed.dart';

@injectable
class TonWalletSentTransactionsBloc extends Bloc<_Event, List<Tuple2<PendingTransaction, Transaction?>>> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onMessageSentSubscription;

  TonWalletSentTransactionsBloc(this._nekotonService) : super(const []);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onMessageSentSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<List<Tuple2<PendingTransaction, Transaction?>>> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        yield const [];

        final address = event.address;

        _streamSubscription?.cancel();
        _onMessageSentSubscription?.cancel();

        _streamSubscription =
            _nekotonService.tonWalletsStream.expand((e) => e).where((e) => e.address == address).listen((event) {
          final tonWallet = event;

          _onMessageSentSubscription?.cancel();

          _onMessageSentSubscription = tonWallet.onMessageSentStream.listen(
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
  const factory _LocalEvent.update(List<Tuple2<PendingTransaction, Transaction?>> transactions) = _Update;
}

@freezed
class TonWalletSentTransactionsEvent extends _Event with _$TonWalletSentTransactionsEvent {
  const factory TonWalletSentTransactionsEvent.load(String address) = _Load;
}
