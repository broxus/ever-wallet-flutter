import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/wallet_transaction.dart';
import '../../repositories/ton_wallet_transactions_repository.dart';
import '../../services/nekoton_service.dart';
import '../../utils/transaction_data.dart';
import '../../utils/transaction_time.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

@injectable
class TonWalletTransactionsBloc extends Bloc<_Event, TonWalletTransactionsState> {
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
  ) : super(const TonWalletTransactionsState([]));

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
  Stream<TonWalletTransactionsState> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        final tonWalletTransactions = _tonWalletTransactionsRepository.get(event.address);

        if (tonWalletTransactions != null) {
          _nekotonService.tonWalletsStream
              .expand((e) => e)
              .where((e) => e.address == event.address)
              .first
              .then((value) => add(_LocalEvent.update(
                    tonWallet: value,
                    transactions: tonWalletTransactions,
                  )));
        }

        _streamSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();
        _onMessageSentSubscription?.cancel();
        _onMessageExpiredSubscription?.cancel();
        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == event.address)
            .distinct()
            .listen((tonWalletEvent) {
          _onTransactionsFoundSubscription?.cancel();
          _onMessageSentSubscription?.cancel();
          _onMessageExpiredSubscription?.cancel();
          _preloadTransactions = tonWalletEvent.preloadTransactions;
          _onTransactionsFoundSubscription =
              tonWalletEvent.onTransactionsFoundStream.listen((event) => add(_LocalEvent.update(
                    tonWallet: tonWalletEvent,
                    transactions: event,
                  )));
          _onMessageSentSubscription = tonWalletEvent.onMessageSentStream.listen((event) => add(_LocalEvent.updateSent(
                tonWallet: tonWalletEvent,
                transactions: event,
              )));
          _onMessageExpiredSubscription =
              tonWalletEvent.onMessageExpiredStream.listen((event) => add(_LocalEvent.updateExpired(
                    tonWallet: tonWalletEvent,
                    transactions: event,
                  )));
        });
      } else if (event is _Preload) {
        final prevTransactionId = state.transactions.lastOrNull?.prevTransactionId;

        if (prevTransactionId != null) {
          await _preloadTransactions?.call(prevTransactionId);
        }
      } else if (event is _Update) {
        final transactions = event.transactions.map((e) {
          final transaction = e.transaction;
          final data = e.data;

          final isOutgoing = transaction.outMessages.isNotEmpty;

          final address = isOutgoing ? transaction.outMessages.first.dst : transaction.inMessage.src;
          final value = isOutgoing ? transaction.outMessages.first.value : transaction.inMessage.value;

          return WalletTransaction.ordinary(
            hash: transaction.id.hash,
            prevTransactionId: transaction.prevTransactionId,
            totalFees: transaction.totalFees.toTokens(),
            address: address ?? '',
            value: value.toTokens(),
            createdAt: transaction.createdAt.toDateTime(),
            isOutgoing: isOutgoing,
            currency: 'TON',
            feesCurrency: 'TON',
            data: data?.toComment(),
          );
        }).toList();

        yield TonWalletTransactionsState(transactions);

        await _tonWalletTransactionsRepository.save(
          tonWalletTransactions: event.transactions,
          address: event.tonWallet.address,
        );
      } else if (event is _UpdateSent) {
        // TODO: Implement _UpdateSent and check if this is realy working in nekoton
      } else if (event is _UpdateExpired) {
        // TODO: Implement _UpdateExpired and check if this is realy working in nekoton
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
    required TonWallet tonWallet,
    required List<TonWalletTransactionWithData> transactions,
  }) = _Update;

  const factory _LocalEvent.updateSent({
    required TonWallet tonWallet,
    required List<Transaction> transactions,
  }) = _UpdateSent;

  const factory _LocalEvent.updateExpired({
    required TonWallet tonWallet,
    required List<Transaction> transactions,
  }) = _UpdateExpired;
}

@freezed
class TonWalletTransactionsEvent extends _Event with _$TonWalletTransactionsEvent {
  const factory TonWalletTransactionsEvent.load(String address) = _Load;

  const factory TonWalletTransactionsEvent.preload() = _Preload;
}

@freezed
class TonWalletTransactionsState with _$TonWalletTransactionsState {
  const factory TonWalletTransactionsState(List<WalletTransaction> transactions) = _TonWalletTransactionsState;
}
