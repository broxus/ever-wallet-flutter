import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'current_account_bloc.freezed.dart';

@injectable
class CurrentAccountBloc extends Bloc<_Event, AssetsList?> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  late final StreamSubscription _streamSubscription;

  CurrentAccountBloc(this._nekotonService) : super(null) {
    _streamSubscription =
        Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>, Map<String, List<String>>, List<AssetsList>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      _nekotonService.externalAccountsStream,
      (a, b, c) {
        final currentKey = a;

        List<AssetsList> internalAccounts = [];
        List<AssetsList> externalAccounts = [];

        if (currentKey != null) {
          final externalAddresses = c[a?.publicKey] ?? [];

          internalAccounts = b.where((e) => e.publicKey == a?.publicKey).toList();
          externalAccounts =
              b.where((e) => e.publicKey != a?.publicKey && externalAddresses.any((el) => el == e.address)).toList();
        }

        return [
          ...internalAccounts,
          ...externalAccounts,
        ]..sort((a, b) => a.name.compareTo(b.name));
      },
    ).listen((event) => add(_LocalEvent.update(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AssetsList?> mapEventToState(_Event event) async* {
    try {
      if (event is _SetCurrent) {
        final account = _nekotonService.accounts.firstWhereOrNull((e) => e.address == event.address);

        yield account;
      } else if (event is _Update) {
        final currentAccount =
            event.accounts.firstWhereOrNull((e) => e.address == state?.address) ?? event.accounts.firstOrNull;

        yield currentAccount;
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update(List<AssetsList> accounts) = _Update;
}

@freezed
class CurrentAccountEvent extends _Event with _$CurrentAccountEvent {
  const factory CurrentAccountEvent.setCurrent([String? address]) = _SetCurrent;
}
