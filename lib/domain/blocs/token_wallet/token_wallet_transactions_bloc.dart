import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/token_wallet_transactions_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'token_wallet_transactions_bloc.freezed.dart';

@injectable
class TokenWalletTransactionsBloc extends Bloc<_Event, List<TokenWalletTransactionWithData>> {
  final NekotonService _nekotonService;
  final TokenWalletTransactionsRepository _tokenWalletTransactionsRepository;
  final _errorsSubject = PublishSubject<Exception>();
  final _sideEffectsSubject = PublishSubject<bool>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  Future<void> Function(TransactionId from)? _preloadTransactions;

  TokenWalletTransactionsBloc(
    this._nekotonService,
    this._tokenWalletTransactionsRepository,
  ) : super(const <TokenWalletTransactionWithData>[]);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _sideEffectsSubject.close();
    _onTransactionsFoundSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<List<TokenWalletTransactionWithData>> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        yield const [];

        _sideEffectsSubject.add(true);

        final owner = event.owner;
        final rootTokenContract = event.rootTokenContract;

        final tokenWalletTransactions = _tokenWalletTransactionsRepository.get(
          owner: event.owner,
          rootTokenContract: event.rootTokenContract,
        );

        if (tokenWalletTransactions != null) {
          add(
            _LocalEvent.update(
              owner: owner,
              rootTokenContract: rootTokenContract,
              transactions: tokenWalletTransactions,
            ),
          );
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

          _onTransactionsFoundSubscription = tokenWalletEvent.onTransactionsFoundStream
              .map((e) => e.where((e) => e.data != null).toList())
              .where((e) => e.isNotEmpty)
              .listen(
                (event) => add(
                  _LocalEvent.update(
                    owner: owner,
                    rootTokenContract: rootTokenContract,
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

        await _tokenWalletTransactionsRepository.save(
          owner: event.owner,
          rootTokenContract: event.rootTokenContract,
          tokenWalletTransactions: transactions,
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
    required String owner,
    required String rootTokenContract,
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
