import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_info_bloc.freezed.dart';

@injectable
class AccountInfoBloc extends Bloc<AccountInfoEvent, AccountInfoState> {
  final NekotonService _nekotonService;
  final String? _address;
  late final StreamSubscription _streamSubscription;

  AccountInfoBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(AccountInfoState.ready(_nekotonService.accounts.firstWhere((e) => e.address == _address!).name)) {
    _streamSubscription = _nekotonService.accountsStream.transform<AssetsList>(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        final entry = data.firstWhereOrNull((e) => e.address == _address!);

        if (entry != null) {
          sink.add(entry);
        }
      },
    )).listen((value) => add(AccountInfoEvent.update(value)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AccountInfoState> mapEventToState(AccountInfoEvent event) async* {
    yield* event.when(
      update: (AssetsList account) async* {
        try {
          yield AccountInfoState.ready(account.name);
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
  const factory AccountInfoEvent.update(AssetsList account) = _Update;
}

@freezed
class AccountInfoState with _$AccountInfoState {
  const factory AccountInfoState.ready(String name) = _Ready;

  const factory AccountInfoState.error(String info) = _Error;
}
