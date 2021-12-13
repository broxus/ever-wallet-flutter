import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/ton_wallet_transactions_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

@injectable
class TonWalletTransactionsBloc extends Bloc<_Event, List<TonWalletTransactionWithData>> {
  final NekotonService _nekotonService;
  final TonWalletTransactionsRepository _tonWalletTransactionsRepository;
  final _errorsSubject = PublishSubject<Exception>();
  final _sideEffectsSubject = PublishSubject<bool>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  Future<void> Function(TransactionId from)? _preloadTransactions;

  TonWalletTransactionsBloc(
    this._nekotonService,
    this._tonWalletTransactionsRepository,
  ) : super(const <TonWalletTransactionWithData>[]);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _sideEffectsSubject.close();
    _streamSubscription?.cancel();
    _onTransactionsFoundSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<List<TonWalletTransactionWithData>> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        yield const [];

        _sideEffectsSubject.add(true);

        final address = event.address;

        final tonWalletTransactions = _tonWalletTransactionsRepository.get(address);

        if (tonWalletTransactions != null) {
          add(
            _LocalEvent.update(
              address: address,
              transactions: tonWalletTransactions,
            ),
          );
        }

        _streamSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();

        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == address)
            .distinct()
            .listen((tonWalletEvent) {
          _onTransactionsFoundSubscription?.cancel();

          _preloadTransactions = tonWalletEvent.preloadTransactions;

          _onTransactionsFoundSubscription = tonWalletEvent.onTransactionsFoundStream.listen(
            (event) => add(
              _LocalEvent.update(
                address: address,
                transactions: event,
              ),
            ),
          );
        });
      } else if (event is _Preload) {
        final prevTransactionId = state.lastOrNull?.transaction.prevTransactionId;

        if (prevTransactionId != null) {
          _sideEffectsSubject.add(true);

          await _preloadTransactions?.call(prevTransactionId);
        }
      } else if (event is _Update) {
        final transactions = [...state]
          ..removeWhere((e) => event.transactions.any((el) => e.transaction.id == el.transaction.id))
          ..addAll(event.transactions)
          ..sort((a, b) => b.transaction.createdAt.compareTo(a.transaction.createdAt));

        yield transactions;

        _sideEffectsSubject.add(false);

        await _tonWalletTransactionsRepository.save(
          address: event.address,
          tonWalletTransactions: transactions,
        );
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;

  Stream<bool> get sideEffectsStream => _sideEffectsSubject.stream.distinct();
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update({
    required String address,
    required List<TonWalletTransactionWithData> transactions,
  }) = _Update;
}

@freezed
class TonWalletTransactionsEvent extends _Event with _$TonWalletTransactionsEvent {
  const factory TonWalletTransactionsEvent.load(String address) = _Load;

  const factory TonWalletTransactionsEvent.preload() = _Preload;
}
