import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
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

  TokenWalletInfoBloc(
    this._nekotonService,
    this._tokenWalletInfoRepository,
  ) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onBalanceChangedSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TokenWalletInfo?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        yield null;

        final owner = event.owner;
        final rootTokenContract = event.rootTokenContract;

        final tokenWalletInfo = _tokenWalletInfoRepository.get(
          owner: owner,
          rootTokenContract: rootTokenContract,
        );

        if (tokenWalletInfo != null) {
          add(_LocalEvent.update(tokenWalletInfo));
        }

        _streamSubscription?.cancel();
        _onBalanceChangedSubscription?.cancel();

        _streamSubscription = _nekotonService.tokenWalletsStream
            .expand((e) => e)
            .where((e) => e.owner == owner && e.symbol.rootTokenContract == rootTokenContract)
            .distinct()
            .listen((event) async {
          final tokenWallet = event;

          _onBalanceChangedSubscription?.cancel();

          _onBalanceChangedSubscription = tokenWallet.onBalanceChangedStream.listen((event) async {
            final tokenWalletInfo = TokenWalletInfo(
              owner: tokenWallet.owner,
              address: tokenWallet.address,
              symbol: tokenWallet.symbol,
              version: tokenWallet.version,
              balance: event,
              contractState: await tokenWallet.contractState,
            );

            add(_LocalEvent.update(tokenWalletInfo));
          });

          final tokenWalletInfo = TokenWalletInfo(
            owner: tokenWallet.owner,
            address: tokenWallet.address,
            symbol: tokenWallet.symbol,
            version: tokenWallet.version,
            balance: await tokenWallet.balance,
            contractState: await tokenWallet.contractState,
          );

          add(_LocalEvent.update(tokenWalletInfo));
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
