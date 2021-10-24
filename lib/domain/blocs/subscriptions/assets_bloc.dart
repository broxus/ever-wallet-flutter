import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../logger.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'assets_bloc.freezed.dart';

typedef TokenWalletWithIcon = Tuple2<TokenWallet, String?>;

@injectable
class AssetsBloc extends Bloc<_Event, AssetsState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;

  AssetsBloc(
    this._nekotonService,
    this._tonAssetsRepository,
  ) : super(const AssetsState());

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<AssetsState> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        _streamSubscription?.cancel();
        _streamSubscription = Rx.combineLatest2<TonWallet, List<TokenWallet>, _LocalEvent>(
          _nekotonService.tonWalletsStream.expand((e) => e).where((e) => e.address == event.address),
          _nekotonService.tokenWalletsStream.map((e) => e.where((e) => e.owner == event.address).toList()),
          (a, b) => _LocalEvent.update(
            tonWallet: a,
            tokenWallets: b,
          ),
        ).listen((event) => add(event));
      } else if (event is _Update) {
        final stream = _tonAssetsRepository.getTokenContractAssetsStream();

        await for (final item in stream) {
          final tokenWalletsWithIcon = <TokenWalletWithIcon>[];

          for (final tokenWallet in event.tokenWallets) {
            final tokenContractAsset =
                item.firstWhereOrNull((element) => element.address == tokenWallet.symbol.rootTokenContract);

            tokenWalletsWithIcon.add(Tuple2(tokenWallet, tokenContractAsset?.logoURI));
          }

          yield AssetsState(
            tonWallet: event.tonWallet,
            tokenWallets: tokenWalletsWithIcon,
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
  const factory _LocalEvent.update({
    required TonWallet tonWallet,
    required List<TokenWallet> tokenWallets,
  }) = _Update;
}

@freezed
class AssetsEvent extends _Event with _$AssetsEvent {
  const factory AssetsEvent.load(String address) = _Load;
}

@freezed
class AssetsState with _$AssetsState {
  const factory AssetsState({
    TonWallet? tonWallet,
    @Default([]) List<TokenWalletWithIcon> tokenWallets,
  }) = _AssetsState;
}
