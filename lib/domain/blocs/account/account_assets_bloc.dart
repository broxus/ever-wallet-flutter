import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/token_contract_asset.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'account_assets_bloc.freezed.dart';

@injectable
class AccountAssetsBloc extends Bloc<_Event, AccountAssetsState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;

  AccountAssetsBloc(
    this._nekotonService,
    this._tonAssetsRepository,
  ) : super(const AccountAssetsState());

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<AccountAssetsState> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        _streamSubscription?.cancel();
        _streamSubscription = _nekotonService.tokenWalletsStream
            .map((e) => e.where((e) => e.owner == event.address).toList())
            .listen(
                (value) => add(_LocalEvent.update(value.map((e) => TokenContractAsset.fromTokenWallet(e)).toList())));

        if (_nekotonService.tokenWallets.where((e) => e.owner == event.address).isEmpty) {
          add(const _LocalEvent.update([]));
        }
      } else if (event is _Update) {
        final added = <TokenContractAsset>[];

        for (final asset in event.assets) {
          added.add(asset.copyWith(logoURI: await _tonAssetsRepository.getTokenLogoUri(asset.address)));
        }

        final stream = _tonAssetsRepository.getTokenContractAssetsStream();

        await for (final item in stream) {
          final available = item.where((e) => added.firstWhereOrNull((el) => el.address == e.address) == null).toList()
            ..sort((a, b) => b.address.compareTo(a.address));

          yield AccountAssetsState(
            added: added,
            available: available,
          );
        }
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
  const factory _LocalEvent.update(List<TokenContractAsset> assets) = _Update;
}

@freezed
class AccountAssetsEvent extends _Event with _$AccountAssetsEvent {
  const factory AccountAssetsEvent.load(String address) = _Load;
}

@freezed
class AccountAssetsState with _$AccountAssetsState {
  const factory AccountAssetsState({
    @Default([]) List<TokenContractAsset> added,
    @Default([]) List<TokenContractAsset> available,
  }) = _AccountAssetsState;
}
