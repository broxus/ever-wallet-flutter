import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_transactions_bloc.freezed.dart';

class TonWalletTransactionsBloc extends Bloc<_Event, TonWalletTransactionsState> {
  final TonWalletsRepository _tonWalletsRepository;
  final String _address;
  late final StreamSubscription _transactionsStreamSubscription;

  TonWalletTransactionsBloc(
    this._tonWalletsRepository,
    this._address,
  ) : super(const TonWalletTransactionsState.initial()) {
    _transactionsStreamSubscription = _tonWalletsRepository
        .getTransactionsStream(_address)
        .listen((event) => _transactionsStreamListener(event));

    on<_Update>(
      (event, emit) async {
        emit(TonWalletTransactionsState.ready(event.transactions));
      },
    );

    on<_Preload>(
      (event, emit) async {
        final transactions = state.when(
          initial: () => <TonWalletTransactionWithData>[],
          loading: (transactions) => transactions,
          ready: (transactions) => transactions,
          error: (error) => <TonWalletTransactionWithData>[],
        );

        emit(TonWalletTransactionsState.loading(transactions));

        await _tonWalletsRepository.preloadTransactions(
          address: _address,
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

  void _transactionsStreamListener(List<TonWalletTransactionWithData>? event) {
    if (event != null) _InternalEvent.update(event);
  }
}

abstract class _Event {}

@freezed
class _InternalEvent with _$_InternalEvent implements _Event {
  const factory _InternalEvent.update(List<TonWalletTransactionWithData> transactions) = _Update;
}

@freezed
class TonWalletTransactionsEvent with _$TonWalletTransactionsEvent implements _Event {
  const factory TonWalletTransactionsEvent.preload(TransactionId from) = _Preload;
}

@freezed
class TonWalletTransactionsState with _$TonWalletTransactionsState {
  const factory TonWalletTransactionsState.initial() = _Initial;

  const factory TonWalletTransactionsState.loading(
    List<TonWalletTransactionWithData> transactions,
  ) = _Loading;

  const factory TonWalletTransactionsState.ready(
    List<TonWalletTransactionWithData> transactions,
  ) = _Ready;

  const factory TonWalletTransactionsState.error(String error) = _Error;
}
