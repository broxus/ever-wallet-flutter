import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../models/wallet_transaction.dart';
import '../../services/nekoton_service.dart';
import '../../utils/transaction_data.dart';
import '../../utils/transaction_time.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

@injectable
class TonWalletTransactionsBloc extends Bloc<_Event, TonWalletTransactionsState> {
  final NekotonService _nekotonService;
  final String? _address;
  StreamSubscription? _onMessageExpiredSubscription;
  StreamSubscription? _onMessageSentSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  final _expired = <WalletTransaction>[];
  final _sent = <WalletTransaction>[];
  final _ordinary = <WalletTransaction>[];
  final _transactions = <WalletTransaction>[];

  TonWalletTransactionsBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletTransactionsState.ready(
          transactions: [],
        )) {
    _nekotonService.tonWalletsStream.expand((e) => e).firstWhere((e) => e.address == _address!).then((value) {
      _onMessageExpiredSubscription = value.onMessageExpiredStream.listen(
        (List<Transaction> expired) => add(
          _LocalEvent.updateExpiredMessages(expired),
        ),
      );
      _onMessageSentSubscription = value.onMessageSentStream.listen(
        (List<Transaction> sent) => add(
          _LocalEvent.updateSentMessages(sent),
        ),
      );
      _onTransactionsFoundSubscription = value.onTransactionsFoundStream.listen(
        (List<TonWalletTransactionWithData> transactions) => add(
          _LocalEvent.updateTransactions(transactions),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _onMessageExpiredSubscription?.cancel();
    _onMessageSentSubscription?.cancel();
    _onTransactionsFoundSubscription?.cancel();
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
                      prevTransactionId: e.prevTransactionId,
                      totalFees: e.totalFees.toTokens(),
                      address: e.outMessages.first.dst ?? '',
                      value: e.outMessages.first.value.toTokens(),
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
                      prevTransactionId: e.prevTransactionId,
                      totalFees: e.totalFees.toTokens(),
                      address: e.outMessages.first.dst ?? '',
                      value: e.outMessages.first.value.toTokens(),
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
            final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

            if (_transactions.isNotEmpty) {
              final prevTransactionId = _transactions.last.prevTransactionId;

              if (prevTransactionId != null) {
                await tonWallet.preloadTransactions(prevTransactionId);
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
