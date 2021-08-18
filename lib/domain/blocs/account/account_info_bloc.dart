import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'account_info_bloc.freezed.dart';

@injectable
class AccountInfoBloc extends Bloc<AccountInfoEvent, AccountInfoState> {
  final AccountSubject? _account;
  late final StreamSubscription _streamSubscription;

  AccountInfoBloc(@factoryParam this._account) : super(AccountInfoState.ready(_account!.value.name)) {
    _streamSubscription = _account!.listen((value) => add(AccountInfoEvent.updateName(value.name)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AccountInfoState> mapEventToState(AccountInfoEvent event) async* {
    yield* event.when(
      updateName: (String name) async* {
        try {
          yield AccountInfoState.ready(name);
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield AccountInfoState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class AccountInfoEvent with _$AccountInfoEvent {
  const factory AccountInfoEvent.updateName(String name) = _UpdateName;
}

@freezed
class AccountInfoState with _$AccountInfoState {
  const factory AccountInfoState.ready(String name) = _Ready;

  const factory AccountInfoState.error(String info) = _Error;
}
