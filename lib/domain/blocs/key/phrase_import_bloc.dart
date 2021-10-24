import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';

part 'phrase_import_bloc.freezed.dart';

@injectable
class PhraseImportBloc extends Bloc<PhraseImportEvent, PhraseImportState> {
  final _errorsSubject = PublishSubject<String>();

  PhraseImportBloc() : super(const PhraseImportState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<PhraseImportState> mapEventToState(PhraseImportEvent event) async* {
    try {
      if (event is _Submit) {
        final mnemonicType = event.phrase.length == 24 ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

        deriveFromPhrase(
          phrase: event.phrase,
          mnemonicType: mnemonicType,
        );

        yield const PhraseImportState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class PhraseImportEvent with _$PhraseImportEvent {
  const factory PhraseImportEvent.submit(List<String> phrase) = _Submit;
}

@freezed
class PhraseImportState with _$PhraseImportState {
  const factory PhraseImportState.initial() = _Initial;

  const factory PhraseImportState.success() = _Success;
}
