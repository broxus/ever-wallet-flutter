import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_assets_addition_bloc.freezed.dart';

@injectable
class AccountAssetsAdditionBloc extends Bloc<AccountAssetsAdditionEvent, AccountAssetsAdditionState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  AccountAssetsAdditionBloc(this._nekotonService) : super(const AccountAssetsAdditionState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<AccountAssetsAdditionState> mapEventToState(AccountAssetsAdditionEvent event) async* {
    try {
      if (event is _Add) {
        await _nekotonService.addTokenWallet(
          address: event.address,
          rootTokenContract: event.rootTokenContract,
        );

        yield const AccountAssetsAdditionState.success();
      } else if (event is _Remove) {
        await _nekotonService.removeTokenWallet(
          address: event.address,
          rootTokenContract: event.rootTokenContract,
        );

        yield const AccountAssetsAdditionState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
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

@freezed
class AccountAssetsAdditionState with _$AccountAssetsAdditionState {
  const factory AccountAssetsAdditionState.initial() = _Initial;

  const factory AccountAssetsAdditionState.success() = _Success;
}
