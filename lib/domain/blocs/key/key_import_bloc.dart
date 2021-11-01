import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';

part 'key_import_bloc.freezed.dart';

@injectable
class KeyImportBloc extends Bloc<KeyImportEvent, KeyImportState> {
  final _errorsSubject = PublishSubject<String>();

  KeyImportBloc() : super(const KeyImportState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<KeyImportState> mapEventToState(KeyImportEvent event) async* {
    try {
      if (event is _Submit) {
        final mnemonicType = event.phrase.length == 24 ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

        deriveFromPhrase(
          phrase: event.phrase,
          mnemonicType: mnemonicType,
        );

        yield const KeyImportState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class KeyImportEvent with _$KeyImportEvent {
  const factory KeyImportEvent.submit(List<String> phrase) = _Submit;
}

@freezed
class KeyImportState with _$KeyImportState {
  const factory KeyImportState.initial() = _Initial;

  const factory KeyImportState.success() = _Success;
}
