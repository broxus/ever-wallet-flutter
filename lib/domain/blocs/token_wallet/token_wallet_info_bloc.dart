import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_info_bloc.freezed.dart';

@injectable
class TokenWalletInfoBloc extends Bloc<_Event, TokenWalletInfoState?> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onBalanceChangedSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;

  TokenWalletInfoBloc(
    this._nekotonService,
    this._tonAssetsRepository,
  ) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onBalanceChangedSubscription?.cancel();
    _onTransactionsFoundSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TokenWalletInfoState?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        _streamSubscription?.cancel();
        _onBalanceChangedSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();
        _streamSubscription = _nekotonService.tokenWalletsStream
            .expand((e) => e)
            .where((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract)
            .listen((tokenWalletEvent) {
          _onBalanceChangedSubscription?.cancel();
          _onBalanceChangedSubscription =
              tokenWalletEvent.onBalanceChangedStream.listen((event) => add(_LocalEvent.update(
                    tokenWallet: tokenWalletEvent,
                    balance: event,
                  )));

          _onTransactionsFoundSubscription?.cancel();
          _onTransactionsFoundSubscription = tokenWalletEvent.onTransactionsFoundStream
              .expand((e) => e)
              .map((e) => e.transaction)
              .where((e) => e.prevTransactionId == null)
              .listen((event) async => add(_LocalEvent.update(
                    tokenWallet: tokenWalletEvent,
                    balance: await tokenWalletEvent.balance,
                  )));
        });
      } else if (event is _Update) {
        final balance = event.balance.toTokens(event.tokenWallet.symbol.decimals);
        final contractState = await event.tokenWallet.contractState;
        final logoURI =
            state?.logoURI ?? await _tonAssetsRepository.getTokenLogoUri(event.tokenWallet.symbol.rootTokenContract);

        yield TokenWalletInfoState(
          logoURI: logoURI,
          address: event.tokenWallet.address,
          balance: balance,
          contractState: contractState,
          owner: event.tokenWallet.owner,
          symbol: event.tokenWallet.symbol,
          version: event.tokenWallet.version,
          ownerPublicKey: event.tokenWallet.ownerPublicKey,
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
    required String balance,
  }) = _Update;
}

@freezed
class TokenWalletInfoEvent extends _Event with _$TokenWalletInfoEvent {
  const factory TokenWalletInfoEvent.load({
    required String owner,
    required String rootTokenContract,
  }) = _Load;
}

@freezed
class TokenWalletInfoState with _$TokenWalletInfoState {
  const factory TokenWalletInfoState({
    String? logoURI,
    required String address,
    required String balance,
    required ContractState contractState,
    required String owner,
    required Symbol symbol,
    required TokenWalletVersion version,
    required String ownerPublicKey,
  }) = _TokenWalletInfoState;
}
