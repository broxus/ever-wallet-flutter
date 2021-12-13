import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'account_renaming_bloc.freezed.dart';

@injectable
class AccountRenamingBloc extends Bloc<AccountRenamingEvent, AccountRenamingState> {
  final NekotonService _nekotonService;

  AccountRenamingBloc(this._nekotonService) : super(const AccountRenamingState.initial());

  @override
  Stream<AccountRenamingState> mapEventToState(AccountRenamingEvent event) async* {
    try {
      if (event is _Rename) {
        await _nekotonService.renameAccount(
          address: event.address,
          name: event.name,
        );

        yield const AccountRenamingState.success();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield AccountRenamingState.error(err);
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

@freezed
class AccountRenamingState with _$AccountRenamingState {
  const factory AccountRenamingState.initial() = _Initial;

  const factory AccountRenamingState.success() = _Success;

  const factory AccountRenamingState.error(Exception exception) = _Error;

  const AccountRenamingState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
