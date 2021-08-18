import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../models/wallet_transaction.dart';
import '../../utils/transaction_data.dart';
import '../../utils/transaction_time.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

@injectable
class TonWalletTransactionsBloc extends Bloc<_Event, TonWalletTransactionsState> {
  final TonWallet? _tonWallet;
  late final StreamSubscription _onMessageExpiredSubscription;
  late final StreamSubscription _onMessageSentSubscription;
  late final StreamSubscription _onTransactionsFoundSubscription;
  final _expired = <WalletTransaction>[];
  final _sent = <WalletTransaction>[];
  final _ordinary = <WalletTransaction>[];
  final _transactions = <WalletTransaction>[];

  TonWalletTransactionsBloc(@factoryParam this._tonWallet)
      : super(const TonWalletTransactionsState.ready(
          transactions: [],
        )) {
    _onMessageExpiredSubscription = _tonWallet!.onMessageExpiredStream.listen(
      (List<Transaction> expired) => add(
        _LocalEvent.updateExpiredMessages(expired),
      ),
    );
    _onMessageSentSubscription = _tonWallet!.onMessageSentStream.listen(
      (List<Transaction> sent) => add(
        _LocalEvent.updateSentMessages(sent),
      ),
    );
    _onTransactionsFoundSubscription = _tonWallet!.onTransactionsFoundStream.listen(
      (List<TonWalletTransactionWithData> transactions) => add(
        _LocalEvent.updateTransactions(transactions),
      ),
    );
  }

  @override
  Future<void> close() {
    _onMessageExpiredSubscription.cancel();
    _onMessageSentSubscription.cancel();
    _onTransactionsFoundSubscription.cancel();
    return super.close();
  }

  @override
  Stream<TonWalletTransactionsState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateExpiredMessages: (List<Transaction> expired) async* {
          try {
            final walletTransactions = expired
                .map((e) => WalletTransaction.expired(
                      hash: e.id.hash,
                      prevTransId: e.prevTransId,
                      totalFees: e.totalFees.toTokens(),
                      address: e.outMsgs.first.dst ?? '',
                      value: e.outMsgs.first.value.toTokens(),
                      createdAt: e.createdAt.toDateTime(),
                      isOutgoing: true,
                      currency: 'TON',
                      feesCurrency: 'TON',
                    ))
                .toList();

            _expired
              ..clear()
              ..addAll(walletTransactions);

            mergeLists();

            yield TonWalletTransactionsState.ready(
              transactions: [..._transactions],
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletTransactionsState.error(err.toString());
          }
        },
        updateSentMessages: (List<Transaction> sent) async* {
          try {
            final walletTransactions = sent
                .map((e) => WalletTransaction.sent(
                      hash: e.id.hash,
                      prevTransId: e.prevTransId,
                      totalFees: e.totalFees.toTokens(),
                      address: e.outMsgs.first.dst ?? '',
                      value: e.outMsgs.first.value.toTokens(),
                      createdAt: e.createdAt.toDateTime(),
                      isOutgoing: true,
                      currency: 'TON',
                      feesCurrency: 'TON',
                    ))
                .toList();

            _sent
              ..clear()
              ..addAll(walletTransactions);

            mergeLists();

            yield TonWalletTransactionsState.ready(
              transactions: [..._transactions],
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletTransactionsState.error(err.toString());
          }
        },
        updateTransactions: (List<TonWalletTransactionWithData> transactions) async* {
          try {
            final walletTransactions = transactions.map((e) {
              final transaction = e.transaction;
              final data = e.data;

              final isOutgoing = transaction.outMsgs.isNotEmpty;

              final address = isOutgoing ? transaction.outMsgs.first.dst : transaction.inMsg.src;
              final value = isOutgoing ? transaction.outMsgs.first.value : transaction.inMsg.value;

              return WalletTransaction.ordinary(
                hash: transaction.id.hash,
                prevTransId: transaction.prevTransId,
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

            _ordinary
              ..clear()
              ..addAll(walletTransactions);

            mergeLists();

            yield TonWalletTransactionsState.ready(
              transactions: [..._transactions],
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletTransactionsState.error(err.toString());
          }
        },
      );
    }

    if (event is TonWalletTransactionsEvent) {
      yield* event.when(
        preloadTransactions: () async* {
          try {
            if (_transactions.isNotEmpty) {
              final prevTransId = _transactions.last.prevTransId;

              if (prevTransId != null) {
                await _tonWallet!.preloadTransactions(prevTransId);
              }
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletTransactionsState.error(err.toString());
          }
        },
      );
    }
  }

  void mergeLists() {
    _transactions
      ..clear()
      ..addAll([
        ..._sent,
        ..._expired,
        ..._ordinary,
      ])
      ..sort((a, b) {
        final bCreatedAt = b.map(
          ordinary: (v) => v.createdAt,
          sent: (v) => v.createdAt,
          expired: (v) => v.createdAt,
        );

        final aCreatedAt = a.map(
          ordinary: (v) => v.createdAt,
          sent: (v) => v.createdAt,
          expired: (v) => v.createdAt,
        );

        return bCreatedAt.compareTo(aCreatedAt);
      });
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateExpiredMessages(
    List<Transaction> expired,
  ) = _UpdateExpiredMessages;

  const factory _LocalEvent.updateSentMessages(
    List<Transaction> sent,
  ) = _UpdateSentMessages;

  const factory _LocalEvent.updateTransactions(
    List<TonWalletTransactionWithData> transactions,
  ) = _UpdateTransactions;
}

@freezed
class TonWalletTransactionsEvent extends _Event with _$TonWalletTransactionsEvent {
  const factory TonWalletTransactionsEvent.preloadTransactions() = _PreloadTransactions;
}

@freezed
class TonWalletTransactionsState with _$TonWalletTransactionsState {
  const factory TonWalletTransactionsState.initial() = _Initial;

  const factory TonWalletTransactionsState.ready({
    required List<WalletTransaction> transactions,
  }) = _Ready;

  const factory TonWalletTransactionsState.error(String info) = _Error;
}
