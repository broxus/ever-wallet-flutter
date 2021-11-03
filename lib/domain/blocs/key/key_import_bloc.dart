import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'key_import_bloc.freezed.dart';

@injectable
class KeyImportBloc extends Bloc<KeyImportEvent, KeyImportState> {
  KeyImportBloc() : super(KeyImportStateInitial());

  @override
  Stream<KeyImportState> mapEventToState(KeyImportEvent event) async* {
    try {
      if (event is _Import) {
        final mnemonicType = event.phrase.length == 24 ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

        deriveFromPhrase(
          phrase: event.phrase,
          mnemonicType: mnemonicType,
        );

        yield KeyImportStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyImportStateError(err);
    }
  }
}

@freezed
class KeyImportEvent with _$KeyImportEvent {
  const factory KeyImportEvent.import(List<String> phrase) = _Import;
}

abstract class KeyImportState {}

class KeyImportStateInitial extends KeyImportState {}

class KeyImportStateSuccess extends KeyImportState {}

class KeyImportStateError extends KeyImportState {
  final Exception exception;

  KeyImportStateError(this.exception);
}
