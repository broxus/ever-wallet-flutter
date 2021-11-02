import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/domain/repositories/token_wallet_info_repository.dart';
import 'package:crystal/domain/repositories/token_wallet_transactions_repository.dart';
import 'package:crystal/domain/repositories/ton_wallet_info_repository.dart';
import 'package:crystal/domain/repositories/ton_wallet_transactions_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../logger.dart';
import '../repositories/biometry_repository.dart';
import '../repositories/ton_assets_repository.dart';
import '../services/nekoton_service.dart';

part 'application_flow_bloc.freezed.dart';

@injectable
class ApplicationFlowBloc extends Bloc<_Event, ApplicationFlowState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;
  final TonAssetsRepository _tonAssetsRepository;
  final TonWalletInfoRepository _tonWalletInfoRepository;
  final TokenWalletInfoRepository _tokenWalletInfoRepository;
  final TonWalletTransactionsRepository _tonWalletTransactionsRepository;
  final TokenWalletTransactionsRepository _tokenWalletTransactionsRepository;
  final _errorsSubject = PublishSubject<String>();
  late final StreamSubscription _streamSubscription;

  ApplicationFlowBloc(
    this._nekotonService,
    this._biometryRepository,
    this._tonAssetsRepository,
    this._tonWalletInfoRepository,
    this._tokenWalletInfoRepository,
    this._tonWalletTransactionsRepository,
    this._tokenWalletTransactionsRepository,
  ) : super(const ApplicationFlowState.loading()) {
    _streamSubscription = _nekotonService.keysPresenceStream.listen((bool hasKeys) => add(_LocalEvent.update(hasKeys)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<ApplicationFlowState> mapEventToState(_Event event) async* {
    try {
      if (event is _Update) {
        if (event.hasKeys) {
          _tonAssetsRepository.refresh();

          yield const ApplicationFlowState.home();
        } else {
          yield const ApplicationFlowState.welcome();
        }
      } else if (event is _LogOut) {
        yield const ApplicationFlowState.loading();

        await _nekotonService.clearAccountsStorage();
        await _nekotonService.clearKeystore();
        await _biometryRepository.clear();
        await _tonAssetsRepository.clear();
        await _tonWalletInfoRepository.clear();
        await _tokenWalletInfoRepository.clear();
        await _tonWalletTransactionsRepository.clear();
        await _tokenWalletTransactionsRepository.clear();
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
  const factory _LocalEvent.update(bool hasKeys) = _Update;
}

@freezed
class ApplicationFlowEvent extends _Event with _$ApplicationFlowEvent {
  const factory ApplicationFlowEvent.logOut() = _LogOut;
}

@freezed
class ApplicationFlowState with _$ApplicationFlowState {
  const factory ApplicationFlowState.loading() = _Loading;

  const factory ApplicationFlowState.welcome() = _Welcome;

  const factory ApplicationFlowState.home() = _Home;
}
