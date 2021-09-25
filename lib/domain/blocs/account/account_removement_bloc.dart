import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_removement_bloc.freezed.dart';

@injectable
class AccountRemovementBloc extends Bloc<AccountRemovementEvent, AccountRemovementState> {
  final NekotonService _nekotonService;

  AccountRemovementBloc(this._nekotonService) : super(const AccountRemovementState.initial());

  @override
  Stream<AccountRemovementState> mapEventToState(AccountRemovementEvent event) async* {
    yield* event.when(
      removeAccount: (String address) async* {
        try {
          await _nekotonService.removeAccount(address);

          yield const AccountRemovementState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield AccountRemovementState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class AccountRemovementEvent with _$AccountRemovementEvent {
  const factory AccountRemovementEvent.removeAccount(String address) = _RemoveAccount;
}

@freezed
class AccountRemovementState with _$AccountRemovementState {
  const factory AccountRemovementState.initial() = _Initial;

  const factory AccountRemovementState.success() = _Success;

  const factory AccountRemovementState.error(String info) = _Error;
}
