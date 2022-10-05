import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/models/token_wallet_ordinary_transaction.dart';
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
        .ordinaryTransactionsStream(
          owner: _owner,
          rootTokenContract: _rootTokenContract,
        )
        .listen((e) => _transactionsStreamListener(e));

    on<_Update>(
      (event, emit) async {
        emit(TokenWalletTransactionsState.ready(event.transactions));
      },
    );

    on<_Preload>(
      (event, emit) async {
        final transactions = state.when(
          initial: () => <TokenWalletOrdinaryTransaction>[],
          loading: (transactions) => transactions,
          ready: (transactions) => transactions,
          error: (error) => <TokenWalletOrdinaryTransaction>[],
        );

        emit(TokenWalletTransactionsState.loading(transactions));

        await _tokenWalletsRepository.preloadTransactions(
          owner: _owner,
          rootTokenContract: _rootTokenContract,
          fromLt: event.from,
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

  void _transactionsStreamListener(List<TokenWalletOrdinaryTransaction>? event) {
    if (event != null) _InternalEvent.update(event);
  }
}

abstract class _Event {}

@freezed
class _InternalEvent with _$_InternalEvent implements _Event {
  const factory _InternalEvent.update(
    List<TokenWalletOrdinaryTransaction> transactions,
  ) = _Update;
}

@freezed
class TokenWalletTransactionsEvent with _$TokenWalletTransactionsEvent implements _Event {
  const factory TokenWalletTransactionsEvent.preload(String from) = _Preload;
}

@freezed
class TokenWalletTransactionsState with _$TokenWalletTransactionsState {
  const factory TokenWalletTransactionsState.initial() = _Initial;

  const factory TokenWalletTransactionsState.loading(
    List<TokenWalletOrdinaryTransaction> transactions,
  ) = _Loading;

  const factory TokenWalletTransactionsState.ready(
    List<TokenWalletOrdinaryTransaction> transactions,
  ) = _Ready;

  const factory TokenWalletTransactionsState.error(String error) = _Error;
}
