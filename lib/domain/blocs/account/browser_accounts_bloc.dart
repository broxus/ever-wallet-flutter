import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'browser_accounts_bloc.freezed.dart';

@injectable
class BrowserAccountsBloc extends Bloc<_Event, List<AssetsList>> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  late final StreamSubscription _streamSubscription;

  BrowserAccountsBloc(this._nekotonService) : super(const []) {
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
        ];
      },
    ).listen((event) => add(_Event.update(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<List<AssetsList>> mapEventToState(_Event event) async* {
    try {
      if (event is _Update) {
        yield event.accounts;
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

@freezed
class _Event with _$_Event {
  const factory _Event.update(List<AssetsList> accounts) = _Update;
}
