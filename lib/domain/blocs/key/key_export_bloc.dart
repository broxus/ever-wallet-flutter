import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'key_export_bloc.freezed.dart';

@injectable
class KeyExportBloc extends Bloc<KeyExportEvent, KeyExportState> {
  final NekotonService _nekotonService;

  KeyExportBloc(this._nekotonService) : super(KeyExportStateInitial());

  @override
  Stream<KeyExportState> mapEventToState(KeyExportEvent event) async* {
    try {
      if (event is _Export) {
        final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == event.publicKey);

        if (key == null) {
          throw KeyNotFoundException();
        }

        late final ExportKeyInput exportKeyInput;

        if (key.isLegacy) {
          exportKeyInput = EncryptedKeyPassword(
            publicKey: key.publicKey,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        } else {
          exportKeyInput = DerivedKeyExportParams(
            masterKey: key.masterKey,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        }

        final output = await _nekotonService.exportKey(exportKeyInput);

        if (output is EncryptedKeyExportOutput) {
          yield KeyExportStateSuccess(output.phrase.split(' '));
        } else if (output is DerivedKeyExportOutput) {
          yield KeyExportStateSuccess(output.phrase.split(' '));
        } else {
          throw UnknownSignerException();
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyExportStateError(err);
    }
  }
}

@freezed
class KeyExportEvent with _$KeyExportEvent {
  const factory KeyExportEvent.export({
    required String publicKey,
    required String password,
  }) = _Export;
}

abstract class KeyExportState {}

class KeyExportStateInitial extends KeyExportState {}

class KeyExportStateSuccess extends KeyExportState {
  final List<String> phrase;

  KeyExportStateSuccess(this.phrase);
}

class KeyExportStateError extends KeyExportState {
  final Exception exception;

  KeyExportStateError(this.exception);
}
