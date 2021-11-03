import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_renaming_bloc.freezed.dart';

@injectable
class AccountRenamingBloc extends Bloc<AccountRenamingEvent, AccountRenamingState> {
  final NekotonService _nekotonService;

  AccountRenamingBloc(this._nekotonService) : super(AccountRenamingStateInitial());

  @override
  Stream<AccountRenamingState> mapEventToState(AccountRenamingEvent event) async* {
    try {
      if (event is _Rename) {
        await _nekotonService.renameAccount(
          address: event.address,
          name: event.name,
        );

        yield AccountRenamingStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield AccountRenamingStateError(err);
    }
  }
}

@freezed
class AccountRenamingEvent with _$AccountRenamingEvent {
  const factory AccountRenamingEvent.rename({
    required String address,
    required String name,
  }) = _Rename;
}

abstract class AccountRenamingState {}

class AccountRenamingStateInitial extends AccountRenamingState {}

class AccountRenamingStateSuccess extends AccountRenamingState {}

class AccountRenamingStateError extends AccountRenamingState {
  final Exception exception;

  AccountRenamingStateError(this.exception);
}
