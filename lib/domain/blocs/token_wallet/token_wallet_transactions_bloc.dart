import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/domain/repositories/token_wallet_transactions_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/wallet_transaction.dart';
import '../../services/nekoton_service.dart';
import '../../utils/transaction_data.dart';
import '../../utils/transaction_time.dart';

part 'token_wallet_transactions_bloc.freezed.dart';

@injectable
class TokenWalletTransactionsBloc extends Bloc<_Event, TokenWalletTransactionsState> {
  final NekotonService _nekotonService;
  final TokenWalletTransactionsRepository _tokenWalletTransactionsRepository;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  Future<void> Function(TransactionId from)? _preloadTransactions;

  TokenWalletTransactionsBloc(
    this._nekotonService,
    this._tokenWalletTransactionsRepository,
  ) : super(const TokenWalletTransactionsState([]));

  @override
  Future<void> close() {
    _errorsSubject.close();
    _onTransactionsFoundSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TokenWalletTransactionsState> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        final tokenWalletTransactions = _tokenWalletTransactionsRepository.get(
          owner: event.owner,
          rootTokenContract: event.rootTokenContract,
        );

        if (tokenWalletTransactions != null) {
          _nekotonService.tokenWalletsStream
              .expand((e) => e)
              .where((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract)
              .first
              .then((value) => add(_LocalEvent.update(
                    tokenWallet: value,
                    transactions: tokenWalletTransactions,
                  )));
        }

        _streamSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();
        _streamSubscription = _nekotonService.tokenWalletsStream
            .expand((e) => e)
            .where((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract)
            .distinct()
            .listen((tokenWalletEvent) {
          _onTransactionsFoundSubscription?.cancel();
          _preloadTransactions = tokenWalletEvent.preloadTransactions;
          _onTransactionsFoundSubscription =
              tokenWalletEvent.onTransactionsFoundStream.listen((event) => add(_LocalEvent.update(
                    tokenWallet: tokenWalletEvent,
                    transactions: event,
                  )));
        });
      } else if (event is _Preload) {
        final prevTransactionId = state.transactions.lastOrNull?.prevTransactionId;

        if (prevTransactionId != null) {
          await _preloadTransactions?.call(prevTransactionId);
        }
      } else if (event is _Update) {
        final transactions = event.transactions.where((e) => e.data != null).map((e) {
          final transaction = e.transaction;
          final data = e.data!;

          final tokenSenderAddress = data.maybeWhen(
            incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
            orElse: () => null,
          );
          final tokenReceiverAddress = data.maybeWhen(
            outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
            swapBack: (tokenSwapBack) => tokenSwapBack.callbackAddress,
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
            prevTransactionId: transaction.prevTransactionId,
            totalFees: transaction.totalFees.toTokens(),
            address: address ?? '',
            value: tokenValue.toTokens(event.tokenWallet.symbol.decimals),
            createdAt: transaction.createdAt.toDateTime(),
            isOutgoing: isOutgoing,
            currency: event.tokenWallet.symbol.name,
            feesCurrency: 'TON',
            data: data.toComment(),
          );
        }).toList();

        yield TokenWalletTransactionsState(transactions);

        await _tokenWalletTransactionsRepository.save(
          tokenWalletTransactions: event.transactions,
          owner: event.tokenWallet.owner,
          rootTokenContract: event.tokenWallet.symbol.rootTokenContract,
        );
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
    required TokenWallet tokenWallet,
    required List<TokenWalletTransactionWithData> transactions,
  }) = _Update;
}

@freezed
class TokenWalletTransactionsEvent extends _Event with _$TokenWalletTransactionsEvent {
  const factory TokenWalletTransactionsEvent.load({
    required String owner,
    required String rootTokenContract,
  }) = _Load;

  const factory TokenWalletTransactionsEvent.preload() = _Preload;
}

@freezed
class TokenWalletTransactionsState with _$TokenWalletTransactionsState {
  const factory TokenWalletTransactionsState(List<WalletTransaction> transactions) = _TokenWalletTransactionsState;
}
