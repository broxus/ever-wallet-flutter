import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_removement_bloc.freezed.dart';

@injectable
class AccountRemovementBloc extends Bloc<AccountRemovementEvent, AccountRemovementState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  AccountRemovementBloc(this._nekotonService) : super(const AccountRemovementState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<AccountRemovementState> mapEventToState(AccountRemovementEvent event) async* {
    try {
      if (event is _Remove) {
        await _nekotonService.removeAccount(event.address);

        yield const AccountRemovementState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class AccountRemovementEvent with _$AccountRemovementEvent {
  const factory AccountRemovementEvent.remove(String address) = _Remove;
}

@freezed
class AccountRemovementState with _$AccountRemovementState {
  const factory AccountRemovementState.initial() = _Initial;

  const factory AccountRemovementState.success() = _Success;
}
