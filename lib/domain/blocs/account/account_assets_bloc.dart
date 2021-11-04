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

part 'account_assets_bloc.freezed.dart';

@injectable
class AccountAssetsBloc extends Bloc<_Event, AccountAssetsState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final _errorsSubject = PublishSubject<Exception>();
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
        final account = _nekotonService.accounts.firstWhereOrNull((e) => e.address == event.address);

        if (account == null) {
          throw AccountNotFoundException();
        }

        final accountAssetsStream = Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
          _nekotonService.accountsStream.expand((e) => e).where((e) => e.address == event.address).distinct(),
          _nekotonService.transportStream,
          (a, b) => Tuple2(a, b),
        ).map((event) {
          final tonWalletAsset = event.item1.tonWallet;
          final tokenWalletAssets = event.item1.additionalAssets.entries
              .where((e) => e.key == event.item2.connectionData.group)
              .map((e) => e.value.tokenWallets)
              .expand((e) => e)
              .toList();

          return Tuple2(
            tonWalletAsset,
            tokenWalletAssets,
          );
        }).distinct((previous, next) => previous.item1 == next.item1 && listEquals(previous.item2, next.item2));

        _streamSubscription?.cancel();
        _streamSubscription = Rx.combineLatest2<
                Tuple2<TonWalletAsset, List<TokenWalletAsset>>,
                List<TokenContractAsset>,
                Tuple2<Tuple2<TonWalletAsset, List<TokenWalletAsset>>, List<TokenContractAsset>>>(
          accountAssetsStream,
          _tonAssetsRepository.assetsStream,
          (a, b) => Tuple2(a, b),
        )
            .distinct((previous, next) =>
                previous.item1.item1 == next.item1.item1 &&
                listEquals(previous.item1.item2, next.item1.item2) &&
                listEquals(previous.item2, next.item2))
            .listen((value) {
          final tonWalletAsset = value.item1.item1;
          final tokenContractAssets = value.item2
              .where((e) => value.item1.item2.any((el) => el.rootTokenContract == e.address))
              .toList()
            ..sort((a, b) => b.address.compareTo(a.address));

          add(_LocalEvent.update(
            tonWalletAsset: tonWalletAsset,
            tokenContractAssets: tokenContractAssets,
          ));
        });
      } else if (event is _Update) {
        yield AccountAssetsState(
          tonWalletAsset: event.tonWalletAsset,
          tokenContractAssets: event.tokenContractAssets,
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
    required TonWalletAsset tonWalletAsset,
    required List<TokenContractAsset> tokenContractAssets,
  }) = _Update;
}

@freezed
class AccountAssetsEvent extends _Event with _$AccountAssetsEvent {
  const factory AccountAssetsEvent.load(String address) = _Load;
}

@freezed
class AccountAssetsState with _$AccountAssetsState {
  const factory AccountAssetsState({
    TonWalletAsset? tonWalletAsset,
    @Default([]) List<TokenContractAsset> tokenContractAssets,
  }) = _AccountAssetsState;
}
