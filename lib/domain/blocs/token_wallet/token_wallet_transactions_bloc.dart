import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../models/wallet_transaction.dart';
import '../../utils/transaction_data.dart';
import '../../utils/transaction_time.dart';

part 'token_wallet_transactions_bloc.freezed.dart';

@injectable
class TokenWalletTransactionsBloc extends Bloc<_Event, TokenWalletTransactionsState> {
  final TokenWallet? _tokenWallet;
  late final StreamSubscription _onTransactionsFoundSubscription;
  final _transactions = <WalletTransaction>[];

  TokenWalletTransactionsBloc(@factoryParam this._tokenWallet) : super(const TokenWalletTransactionsState.ready([])) {
    _onTransactionsFoundSubscription = _tokenWallet!.onTransactionsFoundStream.listen(
      (List<TokenWalletTransactionWithData> transactions) => add(
        _LocalEvent.updateTransactions(transactions),
      ),
    );
  }

  @override
  Future<void> close() {
    _onTransactionsFoundSubscription.cancel();
    return super.close();
  }

  @override
  Stream<TokenWalletTransactionsState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateTransactions: (
          List<TokenWalletTransactionWithData> transactions,
        ) async* {
          try {
            final walletTransactions = transactions.where((e) => e.data != null).map((e) {
              final transaction = e.transaction;
              final data = e.data!;

              final tokenSenderAddress = data.maybeWhen(
                incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
                orElse: () => null,
              );
              final tokenReceiverAddress = data.maybeWhen(
                outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
                swapBack: (tokenSwapBack) => tokenSwapBack.to,
                orElse: () => null,
              );

              final tokenValue = data.when(
                incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
                outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
                swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
                accept: (value) => value,
                transferBounced: (value) => value,
                swapBackBounced: (value) => value,
              );

              final isOutgoing = tokenReceiverAddress != null;

              final address = isOutgoing ? tokenReceiverAddress : tokenSenderAddress;

              return WalletTransaction.ordinary(
                hash: transaction.id.hash,
                prevTransId: transaction.prevTransId,
                totalFees: transaction.totalFees.toTokens(),
                address: address ?? '',
                value: tokenValue.toTokens(_tokenWallet!.symbol.decimals),
                createdAt: transaction.createdAt.toDateTime(),
                isOutgoing: isOutgoing,
                currency: _tokenWallet!.symbol.symbol,
                feesCurrency: 'TON',
                data: data.toComment(),
              );
            }).toList();

            _transactions
              ..clear()
              ..addAll(walletTransactions);

            yield TokenWalletTransactionsState.ready([..._transactions]);
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TokenWalletTransactionsState.error(err.toString());
          }
        },
      );
    }

    if (event is TokenWalletTransactionsEvent) {
      yield* event.when(
        preloadTransactions: () async* {
          try {
            if (_transactions.isNotEmpty) {
              final prevTransId = _transactions.last.prevTransId;

              if (prevTransId != null) {
                await _tokenWallet!.preloadTransactions(prevTransId);
              }
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TokenWalletTransactionsState.error(err.toString());
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateTransactions(
    List<TokenWalletTransactionWithData> transactions,
  ) = _UpdateTransactions;
}

@freezed
class TokenWalletTransactionsEvent extends _Event with _$TokenWalletTransactionsEvent {
  const factory TokenWalletTransactionsEvent.preloadTransactions() = _PreloadTransactions;
}

@freezed
class TokenWalletTransactionsState with _$TokenWalletTransactionsState {
  const factory TokenWalletTransactionsState.ready(
    List<WalletTransaction> transactions,
  ) = _Ready;

  const factory TokenWalletTransactionsState.error(String info) = _Error;
}
