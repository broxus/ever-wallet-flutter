import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../models/token_contract_asset.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'assets_addition_bloc.freezed.dart';

@injectable
class AssetsAdditionBloc extends Bloc<_Event, AssetsAdditionState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final String? _address;
  final _enabled = <TokenContractAsset>[];
  final _available = <TokenContractAsset>[];
  late final StreamSubscription _streamSubscription;

  AssetsAdditionBloc(
    this._nekotonService,
    this._tonAssetsRepository,
    @factoryParam this._address,
  ) : super(const AssetsAdditionState.initial()) {
    _streamSubscription = _nekotonService.tokenWalletsStream
        .map((e) => e.where((e) => e.owner == _address!).toList())
        .listen((event) => add(_LocalEvent.loadAssets(event)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AssetsAdditionState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        loadAssets: (List<TokenWallet> tokenWallets) async* {
          try {
            final stream = _tonAssetsRepository.getTokenContractAssetsStream();

            await for (final item in stream) {
              _available
                ..clear()
                ..addAll(item);

              _enabled.clear();

              for (final tokenWallet in tokenWallets) {
                final asset = _findOrCreateAsset(tokenWallet);
                _enabled.add(asset);
              }

              _enabled.sort((a, b) => b.address.compareTo(a.address));

              _available
                ..addAll(_enabled.where((e) => !_available.contains(e)))
                ..sort((a, b) => b.address.compareTo(a.address));

              yield AssetsAdditionState.ready(
                enabled: [..._enabled],
                available: [..._available],
              );
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield AssetsAdditionState.error(err.toString());
          }
        },
      );
    }

    if (event is AssetsAdditionEvent) {
      yield* event.when(
        addAssets: (List<TokenContractAsset> assets) async* {
          try {
            final enabled = [..._enabled];

            final tokenWallets = _nekotonService.tokenWallets.where((e) => e.owner == _address!);

            final tokenWalletsAddresses = tokenWallets.map((e) => e.symbol.rootTokenContract).toList();

            final addressesForAddition = [...assets]
                .where((e) => !enabled.contains(e))
                .map((e) => e.address)
                .where((e) => !tokenWalletsAddresses.contains(e));
            final addressesForRemovement = [...enabled]
                .where((e) => !assets.contains(e))
                .map((e) => e.address)
                .where((e) => tokenWalletsAddresses.contains(e));

            for (final address in addressesForAddition) {
              await _nekotonService.addTokenWallet(
                address: _address!,
                rootTokenContract: address,
              );
              final tokenWallet = await _nekotonService.tokenWalletsStream
                  .map((e) => e.where((e) => e.owner == _address!).toList())
                  .expand((e) => e)
                  .firstWhere((e) => e.symbol.rootTokenContract == address);

              final asset = _findOrCreateAsset(tokenWallet);
              enabled.add(asset);
            }

            for (final address in addressesForRemovement) {
              enabled.removeWhere((element) => element.address == address);

              await _nekotonService.removeTokenWallet(
                address: _address!,
                rootTokenContract: address,
              );
            }

            _enabled
              ..clear()
              ..addAll(enabled)
              ..sort((a, b) => b.address.compareTo(a.address));

            yield AssetsAdditionState.ready(
              enabled: [..._enabled],
              available: [..._available],
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield AssetsAdditionState.error(err.toString());
          }
        },
        addCustomAsset: (String address) async* {
          try {
            final enabled = [..._enabled];

            final tokenWallets = _nekotonService.tokenWallets.where((e) => e.owner == _address!);

            final tokenWalletsAddresses = tokenWallets.map((e) => e.symbol.rootTokenContract);

            if (!enabled.map((e) => e.address).contains(address) && !tokenWalletsAddresses.contains(address)) {
              await _nekotonService.addTokenWallet(
                address: _address!,
                rootTokenContract: address,
              );

              final tokenWallet = await _nekotonService.tokenWalletsStream
                  .map((e) => e.where((e) => e.owner == _address!).toList())
                  .expand((e) => e)
                  .firstWhere((e) => e.symbol.rootTokenContract == address);

              final asset = _findOrCreateAsset(tokenWallet);
              enabled.add(asset);

              _enabled
                ..clear()
                ..addAll(enabled)
                ..sort((a, b) => b.address.compareTo(a.address));

              yield AssetsAdditionState.ready(
                enabled: [..._enabled],
                available: [..._available],
              );
            } else {
              yield const AssetsAdditionState.error('Asset already added');
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield AssetsAdditionState.error(err.toString());
          }
        },
      );
    }
  }

  TokenContractAsset _findOrCreateAsset(TokenWallet tokenWallet) {
    final symbol = tokenWallet.symbol;
    final version = tokenWallet.version;

    final asset = _available.firstWhereOrNull((element) => element.address == symbol.rootTokenContract);

    if (asset != null) {
      return asset;
    } else {
      final asset = TokenContractAsset(
        name: symbol.name,
        fullName: symbol.fullName,
        decimals: symbol.decimals,
        address: symbol.rootTokenContract,
        version: version.index + 1,
      );

      return asset;
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.loadAssets(List<TokenWallet> tokenWallets) = _LoadAssets;
}

@freezed
class AssetsAdditionEvent extends _Event with _$AssetsAdditionEvent {
  const factory AssetsAdditionEvent.addAssets(List<TokenContractAsset> assets) = _AddAssets;

  const factory AssetsAdditionEvent.addCustomAsset(String address) = _AddCustomAsset;
}

@freezed
class AssetsAdditionState with _$AssetsAdditionState {
  const factory AssetsAdditionState.initial() = _Initial;

  const factory AssetsAdditionState.ready({
    required List<TokenContractAsset> enabled,
    required List<TokenContractAsset> available,
  }) = _Ready;

  const factory AssetsAdditionState.error(String info) = _Error;
}
