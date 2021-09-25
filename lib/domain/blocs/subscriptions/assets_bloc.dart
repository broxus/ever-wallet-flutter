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
class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final String? _address;
  late final StreamSubscription _streamSubscription;

  AssetsBloc(
    this._nekotonService,
    this._tonAssetsRepository,
    @factoryParam this._address,
  ) : super(const AssetsState.initial()) {
    _streamSubscription = Rx.combineLatest2<TonWallet, List<TokenWallet>, AssetsEvent>(
      _nekotonService.tonWalletsStream.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final tonWallet = data.firstWhereOrNull((e) => e.address == _address!);

          if (tonWallet != null) {
            sink.add(tonWallet);
          }
        },
      )),
      _nekotonService.tokenWalletsStream.map((e) => e.where((e) => e.owner == _address!).toList()),
      (a, b) => AssetsEvent.loadAssets(
        tonWallet: a,
        tokenWallets: b,
      ),
    ).listen((event) => add(event));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AssetsState> mapEventToState(AssetsEvent event) async* {
    yield* event.when(
      loadAssets: (
        TonWallet tonWallet,
        List<TokenWallet> tokenWallets,
      ) async* {
        try {
          final stream = _tonAssetsRepository.getTokenContractAssetsStream();

          await for (final item in stream) {
            final tokenWalletsWithIcon = <TokenWalletWithIcon>[];

            for (final tokenWallet in tokenWallets) {
              final address = tokenWallet.symbol.rootTokenContract;
              final tokenContractAsset = item.firstWhereOrNull((element) => element.address == address);
              final logoURI = tokenContractAsset?.logoURI;

              tokenWalletsWithIcon.add(Tuple2(tokenWallet, logoURI));
            }

            yield AssetsState.ready(
              tonWallet: tonWallet,
              tokenWallets: tokenWalletsWithIcon,
            );
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield AssetsState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class AssetsEvent with _$AssetsEvent {
  const factory AssetsEvent.loadAssets({
    required TonWallet tonWallet,
    required List<TokenWallet> tokenWallets,
  }) = _LoadAssets;
}

@freezed
class AssetsState with _$AssetsState {
  const factory AssetsState.initial() = _Initial;

  const factory AssetsState.ready({
    required TonWallet tonWallet,
    required List<TokenWalletWithIcon> tokenWallets,
  }) = _Ready;

  const factory AssetsState.error(String info) = _Error;
}
