import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/wallet_transaction.dart';
import '../../services/nekoton_service.dart';
import '../../utils/transaction_data.dart';
import '../../utils/transaction_time.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

@injectable
class TonWalletTransactionsBloc extends Bloc<_Event, TonWalletTransactionsState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  StreamSubscription? _onMessageSentSubscription;
  StreamSubscription? _onMessageExpiredSubscription;
  Future<void> Function(TransactionId from)? _preloadTransactions;

  TonWalletTransactionsBloc(this._nekotonService) : super(const TonWalletTransactionsState([]));

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
        _streamSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();
        _onMessageSentSubscription?.cancel();
        _onMessageExpiredSubscription?.cancel();
        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == event.address)
            .listen((tonWalletEvent) {
          _onTransactionsFoundSubscription?.cancel();
          _onMessageSentSubscription?.cancel();
          _onMessageExpiredSubscription?.cancel();
          _preloadTransactions = tonWalletEvent.preloadTransactions;
          _onTransactionsFoundSubscription =
              tonWalletEvent.onTransactionsFoundStream.listen((event) async => add(_LocalEvent.update(
                    tokenWallet: tonWalletEvent,
                    transactions: event,
                  )));
          _onMessageSentSubscription =
              tonWalletEvent.onMessageSentStream.listen((event) async => add(_LocalEvent.updateSent(
                    tokenWallet: tonWalletEvent,
                    transactions: event,
                  )));
          _onMessageExpiredSubscription =
              tonWalletEvent.onMessageExpiredStream.listen((event) async => add(_LocalEvent.updateExpired(
                    tokenWallet: tonWalletEvent,
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
      } else if (event is _UpdateSent) {
        // TODO: Implement _UpdateSent and check if this is realy working in nekoton
      } else if (event is _UpdateExpired) {
        // TODO: Implement _UpdateExpired and check if this is realy working in nekoton
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
    required TonWallet tokenWallet,
    required List<TonWalletTransactionWithData> transactions,
  }) = _Update;

  const factory _LocalEvent.updateSent({
    required TonWallet tokenWallet,
    required List<Transaction> transactions,
  }) = _UpdateSent;

  const factory _LocalEvent.updateExpired({
    required TonWallet tokenWallet,
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
