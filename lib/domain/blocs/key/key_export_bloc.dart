import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_export_bloc.freezed.dart';

@injectable
class KeyExportBloc extends Bloc<KeyExportEvent, KeyExportState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  KeyExportBloc(this._nekotonService) : super(const KeyExportState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

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
          yield KeyExportState.success(output.phrase.split(" "));
        } else if (output is DerivedKeyExportOutput) {
          yield KeyExportState.success(output.phrase.split(" "));
        } else {
          throw UnknownSignerException();
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class KeyExportEvent with _$KeyExportEvent {
  const factory KeyExportEvent.export({
    required String publicKey,
    required String password,
  }) = _Export;
}

@freezed
class KeyExportState with _$KeyExportState {
  const factory KeyExportState.initial() = _Initial;

  const factory KeyExportState.success(List<String> phrase) = _Success;
}
