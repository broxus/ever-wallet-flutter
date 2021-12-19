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
    _streamSubscription = Rx.combineLatest2<KeyStoreEntry?, List<AssetsList>, List<AssetsList>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      (a, b) => b.where((e) => e.publicKey == a?.publicKey).toList(),
    ).distinct((previous, next) => listEquals(previous, next)).listen((event) => add(_Event.update(event)));
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
