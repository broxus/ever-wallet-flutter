import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/token_wallet_info.dart';
import '../../repositories/token_wallet_info_repository.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_info_bloc.freezed.dart';

@injectable
class TokenWalletInfoBloc extends Bloc<_Event, TokenWalletInfo?> {
  final NekotonService _nekotonService;
  final TokenWalletInfoRepository _tokenWalletInfoRepository;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onBalanceChangedSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;

  TokenWalletInfoBloc(
    this._nekotonService,
    this._tokenWalletInfoRepository,
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
  Stream<TokenWalletInfo?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        final tokenWalletInfo = _tokenWalletInfoRepository.get(
          owner: event.owner,
          rootTokenContract: event.rootTokenContract,
        );

        if (tokenWalletInfo != null) {
          add(_LocalEvent.update(tokenWalletInfo));
        }

        _streamSubscription?.cancel();
        _onBalanceChangedSubscription?.cancel();
        _onTransactionsFoundSubscription?.cancel();
        _streamSubscription = _nekotonService.tokenWalletsStream
            .expand((e) => e)
            .where((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract)
            .distinct()
            .listen((tokenWalletEvent) {
          _onBalanceChangedSubscription?.cancel();
          _onBalanceChangedSubscription = tokenWalletEvent.onBalanceChangedStream.listen((event) async {
            final contractState = await tokenWalletEvent.contractState;

            add(_LocalEvent.update(TokenWalletInfo(
              address: tokenWalletEvent.address,
              balance: event.toTokens(tokenWalletEvent.symbol.decimals),
              contractState: contractState.copyWith(balance: contractState.balance.toTokens()),
              owner: tokenWalletEvent.owner,
              symbol: tokenWalletEvent.symbol,
              version: tokenWalletEvent.version,
              ownerPublicKey: tokenWalletEvent.ownerPublicKey,
            )));
          });

          _onTransactionsFoundSubscription?.cancel();
          _onTransactionsFoundSubscription = tokenWalletEvent.onTransactionsFoundStream
              .expand((e) => e)
              .map((e) => e.transaction)
              .where((e) => e.prevTransactionId == null)
              .distinct()
              .listen((event) async {
            final balance = await tokenWalletEvent.balance;
            final contractState = await tokenWalletEvent.contractState;

            add(_LocalEvent.update(TokenWalletInfo(
              address: tokenWalletEvent.address,
              balance: balance.toTokens(tokenWalletEvent.symbol.decimals),
              contractState: contractState.copyWith(balance: contractState.balance.toTokens()),
              owner: tokenWalletEvent.owner,
              symbol: tokenWalletEvent.symbol,
              version: tokenWalletEvent.version,
              ownerPublicKey: tokenWalletEvent.ownerPublicKey,
            )));
          });
        });
      } else if (event is _Update) {
        yield event.tokenWalletInfo;

        await _tokenWalletInfoRepository.save(event.tokenWalletInfo);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update(TokenWalletInfo tokenWalletInfo) = _Update;
}

@freezed
class TokenWalletInfoEvent extends _Event with _$TokenWalletInfoEvent {
  const factory TokenWalletInfoEvent.load({
    required String owner,
    required String rootTokenContract,
  }) = _Load;
}
