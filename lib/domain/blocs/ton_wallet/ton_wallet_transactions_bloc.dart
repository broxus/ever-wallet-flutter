import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/ton_wallet_transactions.dart';
import '../../repositories/ton_wallet_transactions_repository.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

@injectable
class TonWalletTransactionsBloc extends Bloc<_Event, TonWalletTransactions> {
  final NekotonService _nekotonService;
  final TonWalletTransactionsRepository _tonWalletTransactionsRepository;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  StreamSubscription? _onMessageSentSubscription;
  StreamSubscription? _onMessageExpiredSubscription;
  Future<void> Function(TransactionId from)? _preloadTransactions;

  TonWalletTransactionsBloc(
    this._nekotonService,
    this._tonWalletTransactionsRepository,
  ) : super(const TonWalletTransactions());

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onTransactionsFoundSubscription?.cancel();
    _onMessageSentSubscription?.cancel();
    _onMessageExpiredSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TonWalletTransactions> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        yield const TonWalletTransactions();

        final address = event.address;

        final tonWalletTransactions = _tonWalletTransactionsRepository.get(address);

        if (tonWalletTransactions != null) {
          add(_LocalEvent.update(
            address: address,
            ordinary: tonWalletTransactions.ordinary,
            sent: tonWalletTransactions.sent,
            expired: tonWalletTransactions.expired,
          ));
        }

        _streamSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();
        _onMessageSentSubscription?.cancel();
        _onMessageExpiredSubscription?.cancel();

        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == address)
            .distinct()
            .listen((tonWalletEvent) {
          _onTransactionsFoundSubscription?.cancel();
          _onMessageSentSubscription?.cancel();
          _onMessageExpiredSubscription?.cancel();

          _preloadTransactions = tonWalletEvent.preloadTransactions;

          _onTransactionsFoundSubscription = tonWalletEvent.onTransactionsFoundStream.listen((event) {
            final ordinary = [...state.ordinary]
              ..removeWhere((e) => event.any((el) => e.transaction.id == el.transaction.id))
              ..addAll(event)
              ..sort((a, b) => a.transaction.createdAt.compareTo(b.transaction.createdAt));

            add(_LocalEvent.update(
              address: address,
              ordinary: ordinary,
            ));
          });

          _onMessageSentSubscription = tonWalletEvent.onMessageSentStream.listen((event) => add(_LocalEvent.update(
                address: address,
                sent: event,
              )));

          _onMessageExpiredSubscription =
              tonWalletEvent.onMessageExpiredStream.listen((event) => add(_LocalEvent.update(
                    address: address,
                    expired: event,
                  )));
        });
      } else if (event is _Preload) {
        final prevTransactionId = state.ordinary.lastOrNull?.transaction.prevTransactionId;

        if (prevTransactionId != null) {
          await _preloadTransactions?.call(prevTransactionId);
        }
      } else if (event is _Update) {
        final tonWalletTransactions = TonWalletTransactions(
          ordinary: event.ordinary ?? state.ordinary,
          sent: event.sent ?? state.sent,
          expired: event.expired ?? state.expired,
        );

        yield tonWalletTransactions;

        await _tonWalletTransactionsRepository.save(
          address: event.address,
          tonWalletTransactions: tonWalletTransactions,
        );
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
  const factory _LocalEvent.update({
    required String address,
    List<TonWalletTransactionWithData>? ordinary,
    List<Transaction>? sent,
    List<Transaction>? expired,
  }) = _Update;
}

@freezed
class TonWalletTransactionsEvent extends _Event with _$TonWalletTransactionsEvent {
  const factory TonWalletTransactionsEvent.load(String address) = _Load;

  const factory TonWalletTransactionsEvent.preload() = _Preload;
}
