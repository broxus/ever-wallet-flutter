import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_renaming_bloc.freezed.dart';

@injectable
class AccountRenamingBloc extends Bloc<AccountRenamingEvent, AccountRenamingState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  AccountRenamingBloc(this._nekotonService) : super(const AccountRenamingState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

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
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
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
}
