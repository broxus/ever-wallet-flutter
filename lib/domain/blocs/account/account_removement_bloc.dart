import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'account_removement_bloc.freezed.dart';

@injectable
class AccountRemovementBloc extends Bloc<AccountRemovementEvent, AccountRemovementState> {
  final NekotonService _nekotonService;

  AccountRemovementBloc(this._nekotonService) : super(AccountRemovementStateInitial());

  @override
  Stream<AccountRemovementState> mapEventToState(AccountRemovementEvent event) async* {
    try {
      if (event is _Remove) {
        await _nekotonService.removeAccount(event.address);

        yield AccountRemovementStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield AccountRemovementStateError(err);
    }
  }
}

@freezed
class AccountRemovementEvent with _$AccountRemovementEvent {
  const factory AccountRemovementEvent.remove(String address) = _Remove;
}

abstract class AccountRemovementState {}

class AccountRemovementStateInitial extends AccountRemovementState {}

class AccountRemovementStateSuccess extends AccountRemovementState {}

class AccountRemovementStateError extends AccountRemovementState {
  final Exception exception;

  AccountRemovementStateError(this.exception);
}
