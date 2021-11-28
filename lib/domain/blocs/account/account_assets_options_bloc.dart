import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../logger.dart';
import '../../models/token_contract_asset.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'account_assets_options_bloc.freezed.dart';

@injectable
class AccountAssetsOptionsBloc extends Bloc<_Event, AccountAssetsOptionsState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;

  AccountAssetsOptionsBloc(
    this._nekotonService,
    this._tonAssetsRepository,
  ) : super(const AccountAssetsOptionsState());

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<AccountAssetsOptionsState> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        final account = _nekotonService.accounts.firstWhereOrNull((e) => e.address == event.address);

        if (account == null) {
          throw AccountNotFoundException();
        }

        final accountAssetsStream = Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
          _nekotonService.accountsStream.expand((e) => e).where((e) => e.address == event.address).distinct(),
          _nekotonService.transportStream,
          (a, b) => Tuple2(a, b),
        )
            .map(
              (event) => event.item1.additionalAssets.entries
                  .where((e) => e.key == event.item2.connectionData.group)
                  .map((e) => e.value.tokenWallets)
                  .expand((e) => e)
                  .toList(),
            )
            .distinct((previous, next) => listEquals(previous, next));

        _streamSubscription?.cancel();
        _streamSubscription = Rx.combineLatest2<List<TokenWalletAsset>, List<TokenContractAsset>,
                Tuple2<List<TokenWalletAsset>, List<TokenContractAsset>>>(
          accountAssetsStream,
          _tonAssetsRepository.assetsStream,
          (a, b) => Tuple2(a, b),
        )
            .distinct(
          (previous, next) => listEquals(previous.item1, next.item1) && listEquals(previous.item2, next.item2),
        )
            .listen((value) {
          final added = value.item2.where((e) => value.item1.any((el) => el.rootTokenContract == e.address)).toList()
            ..sort((a, b) => b.address.compareTo(a.address));

          final available = value.item2
              .where((e) => value.item1.every((el) => el.rootTokenContract != e.address))
              .toList()
            ..sort((a, b) => b.address.compareTo(a.address));

          add(
            _LocalEvent.update(
              added: added,
              available: available,
            ),
          );
        });
      } else if (event is _Update) {
        yield AccountAssetsOptionsState(
          added: event.added,
          available: event.available,
        );
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
  const factory _LocalEvent.update({
    required List<TokenContractAsset> added,
    required List<TokenContractAsset> available,
  }) = _Update;
}

@freezed
class AccountAssetsOptionsEvent extends _Event with _$AccountAssetsOptionsEvent {
  const factory AccountAssetsOptionsEvent.load(String address) = _Load;
}

@freezed
class AccountAssetsOptionsState with _$AccountAssetsOptionsState {
  const factory AccountAssetsOptionsState({
    @Default([]) List<TokenContractAsset> added,
    @Default([]) List<TokenContractAsset> available,
  }) = _AccountAssetsOptionsState;
}
