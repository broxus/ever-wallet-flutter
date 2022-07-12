import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_transactions_bloc.freezed.dart';

class TokenWalletTransactionsBloc extends Bloc<_Event, TokenWalletTransactionsState> {
  final TokenWalletsRepository _tokenWalletsRepository;
  final String _owner;
  final String _rootTokenContract;
  late final StreamSubscription _transactionsStreamSubscription;

  TokenWalletTransactionsBloc(
    this._tokenWalletsRepository,
    this._owner,
    this._rootTokenContract,
  ) : super(const TokenWalletTransactionsState.initial()) {
    _transactionsStreamSubscription = _tokenWalletsRepository
        .getTransactionsStream(
          owner: _owner,
          rootTokenContract: _rootTokenContract,
        )
        .listen((event) => _transactionsStreamListener(event));

    on<_Update>(
      (event, emit) async {
        emit(TokenWalletTransactionsState.ready(event.transactions));
      },
    );

    on<_Preload>(
      (event, emit) async {
        final transactions = state.when(
          initial: () => <TokenWalletTransactionWithData>[],
          loading: (transactions) => transactions,
          ready: (transactions) => transactions,
          error: (error) => <TokenWalletTransactionWithData>[],
        );

        emit(TokenWalletTransactionsState.loading(transactions));

        await _tokenWalletsRepository.preloadTransactions(
          owner: _owner,
          rootTokenContract: _rootTokenContract,
          fromLt: event.from.lt,
        );
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }

  @override
  Future<void> close() async {
    _transactionsStreamSubscription.cancel();
    super.close();
  }

  void _transactionsStreamListener(List<TokenWalletTransactionWithData>? event) {
    if (event != null) _InternalEvent.update(event);
  }
}

abstract class _Event {}

@freezed
class _InternalEvent with _$_InternalEvent implements _Event {
  const factory _InternalEvent.update(List<TokenWalletTransactionWithData> transactions) = _Update;
}

@freezed
class TokenWalletTransactionsEvent with _$TokenWalletTransactionsEvent implements _Event {
  const factory TokenWalletTransactionsEvent.preload(TransactionId from) = _Preload;
}

@freezed
class TokenWalletTransactionsState with _$TokenWalletTransactionsState {
  const factory TokenWalletTransactionsState.initial() = _Initial;

  const factory TokenWalletTransactionsState.loading(
    List<TokenWalletTransactionWithData> transactions,
  ) = _Loading;

  const factory TokenWalletTransactionsState.ready(
    List<TokenWalletTransactionWithData> transactions,
  ) = _Ready;

  const factory TokenWalletTransactionsState.error(String error) = _Error;
}
