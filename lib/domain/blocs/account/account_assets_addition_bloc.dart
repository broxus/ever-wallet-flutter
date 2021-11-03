import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'account_assets_addition_bloc.freezed.dart';

@injectable
class AccountAssetsAdditionBloc extends Bloc<AccountAssetsAdditionEvent, AccountAssetsAdditionState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;

  AccountAssetsAdditionBloc(
    this._nekotonService,
    this._tonAssetsRepository,
  ) : super(AccountAssetsAdditionStateInitial());

  @override
  Stream<AccountAssetsAdditionState> mapEventToState(AccountAssetsAdditionEvent event) async* {
    try {
      if (event is _Add) {
        await _nekotonService.addTokenWallet(
          address: event.address,
          rootTokenContract: event.rootTokenContract,
        );

        if (_tonAssetsRepository.assets.firstWhereOrNull((e) => e.address == event.rootTokenContract) == null) {
          final tokenWalletInfo = await _nekotonService.getTokenWalletInfo(
            address: event.address,
            rootTokenContract: event.rootTokenContract,
          );

          await _tonAssetsRepository.saveCustom(
            name: tokenWalletInfo.name,
            symbol: tokenWalletInfo.symbol,
            decimals: tokenWalletInfo.decimals,
            address: tokenWalletInfo.address,
            version: tokenWalletInfo.version.index + 1,
          );
        }

        yield AccountAssetsAdditionStateSuccess();
      } else if (event is _Remove) {
        await _nekotonService.removeTokenWallet(
          address: event.address,
          rootTokenContract: event.rootTokenContract,
        );

        yield AccountAssetsAdditionStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield AccountAssetsAdditionStateError(err);
    }
  }
}

@freezed
class AccountAssetsAdditionEvent with _$AccountAssetsAdditionEvent {
  const factory AccountAssetsAdditionEvent.add({
    required String address,
    required String rootTokenContract,
  }) = _Add;

  const factory AccountAssetsAdditionEvent.remove({
    required String address,
    required String rootTokenContract,
  }) = _Remove;
}

abstract class AccountAssetsAdditionState {}

class AccountAssetsAdditionStateInitial extends AccountAssetsAdditionState {}

class AccountAssetsAdditionStateSuccess extends AccountAssetsAdditionState {}

class AccountAssetsAdditionStateError extends AccountAssetsAdditionState {
  final Exception exception;

  AccountAssetsAdditionStateError(this.exception);
}
