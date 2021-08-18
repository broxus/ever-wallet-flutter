import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'phrase_import_bloc.freezed.dart';

@injectable
class PhraseImportBloc extends Bloc<PhraseImportEvent, PhraseImportState> {
  PhraseImportBloc() : super(const PhraseImportState.initial());

  @override
  Stream<PhraseImportState> mapEventToState(PhraseImportEvent event) async* {
    yield* event.when(
      submit: (List<String> phrase) async* {
        try {
          yield const PhraseImportState.initial();

          final mnemonicType = phrase.length == 24 ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);
          deriveFromPhrase(
            phrase: phrase,
            mnemonicType: mnemonicType,
          );

          yield PhraseImportState.success(phrase);
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield const PhraseImportState.initial();
          yield PhraseImportState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class PhraseImportEvent with _$PhraseImportEvent {
  const factory PhraseImportEvent.submit(List<String> phrase) = _Submit;
}

@freezed
class PhraseImportState with _$PhraseImportState {
  const factory PhraseImportState.initial() = _Initial;

  const factory PhraseImportState.success(List<String> phrase) = _Success;

  const factory PhraseImportState.error(String info) = _Error;
}
