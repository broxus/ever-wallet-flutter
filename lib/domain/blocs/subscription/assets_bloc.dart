import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../logger.dart';
import '../../repositories/ton_assets_repository.dart';

part 'assets_bloc.freezed.dart';

typedef TokenWalletWithIcon = Tuple2<TokenWallet, String?>;

@injectable
class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  final TonAssetsRepository _tonAssetsRepository;
  final SubscriptionSubject? _subscriptionSubject;
  late final StreamSubscription _streamSubscription;

  AssetsBloc(
    this._tonAssetsRepository,
    @factoryParam this._subscriptionSubject,
  ) : super(const AssetsState.initial()) {
    _streamSubscription = _subscriptionSubject!.listen((value) => add(AssetsEvent.loadAssets(value.tokenWallets)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AssetsState> mapEventToState(AssetsEvent event) async* {
    yield* event.when(
      loadAssets: (List<TokenWallet> tokenWallets) async* {
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
              _subscriptionSubject!.value.tonWallet,
              tokenWalletsWithIcon,
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
  const factory AssetsEvent.loadAssets(List<TokenWallet> tokenWallets) = _LoadAssets;
}

@freezed
class AssetsState with _$AssetsState {
  const factory AssetsState.initial() = _Initial;

  const factory AssetsState.ready(
    TonWallet tonWallet,
    List<TokenWalletWithIcon> tokenWallets,
  ) = _Ready;

  const factory AssetsState.error(String info) = _Error;
}
