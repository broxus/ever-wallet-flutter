import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/subjects.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_multisig_pending_transactions_bloc.freezed.dart';

@injectable
class TonWalletMultisigPendingTransactionsBloc extends Bloc<_Event, List<MultisigPendingTransaction>> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onStateChangedSubscription;

  TonWalletMultisigPendingTransactionsBloc(this._nekotonService) : super([]);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onStateChangedSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<List<MultisigPendingTransaction>> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        yield const [];

        final address = event.address;

        _streamSubscription?.cancel();
        _onStateChangedSubscription?.cancel();

        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == address)
            .distinct()
            .listen((event) async {
          final tonWallet = event;

          _onStateChangedSubscription?.cancel();

          _onStateChangedSubscription = tonWallet.onStateChangedStream.listen(
            (event) async => add(
              _LocalEvent.update(await tonWallet.unconfirmedTransactions),
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
  const factory _LocalEvent.update(List<MultisigPendingTransaction> transactions) = _Update;
}

@freezed
class TonWalletMultisigPendingTransactionsEvent extends _Event with _$TonWalletMultisigPendingTransactionsEvent {
  const factory TonWalletMultisigPendingTransactionsEvent.load(String address) = _Load;
}
