import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

@injectable
class KeyImportBloc extends Bloc<KeyImportEvent, KeyImportState> {
  KeyImportBloc() : super(KeyImportStateInitial());

  @override
  Stream<KeyImportState> mapEventToState(KeyImportEvent event) async* {
    try {
      final mnemonicType = event.phrase.length == 24 ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

      deriveFromPhrase(
        phrase: event.phrase,
        mnemonicType: mnemonicType,
      );

      yield KeyImportStateSuccess();
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyImportStateError(err);
    }
  }
}

class KeyImportEvent {
  final List<String> phrase;

  KeyImportEvent(this.phrase);
}

abstract class KeyImportState {
  KeyImportState();
}

class KeyImportStateInitial extends KeyImportState {
  KeyImportStateInitial();
}

class KeyImportStateSuccess extends KeyImportState {
  KeyImportStateSuccess();
}

class KeyImportStateError extends KeyImportState {
  final Exception exception;

  KeyImportStateError(this.exception);
}
