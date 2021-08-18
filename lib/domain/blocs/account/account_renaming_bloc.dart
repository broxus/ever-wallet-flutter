import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_renaming_bloc.freezed.dart';

@injectable
class AccountRenamingBloc extends Bloc<AccountRenamingEvent, AccountRenamingState> {
  final NekotonService _nekotonService;

  AccountRenamingBloc(this._nekotonService) : super(const AccountRenamingState.initial());

  @override
  Stream<AccountRenamingState> mapEventToState(AccountRenamingEvent event) async* {
    yield* event.when(
      rename: (
        AccountSubject accountSubject,
        String name,
      ) async* {
        try {
          await _nekotonService.renameAccount(
            address: accountSubject.value.address,
            name: name,
          );

          yield const AccountRenamingState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield AccountRenamingState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class AccountRenamingEvent with _$AccountRenamingEvent {
  const factory AccountRenamingEvent.rename({
    required AccountSubject accountSubject,
    required String name,
  }) = _Rename;
}

@freezed
class AccountRenamingState with _$AccountRenamingState {
  const factory AccountRenamingState.initial() = _Initial;

  const factory AccountRenamingState.success() = _Success;

  const factory AccountRenamingState.error(String info) = _Error;
}
