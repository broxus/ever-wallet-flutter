import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_export_bloc.freezed.dart';

@injectable
class KeyExportBloc extends Bloc<KeyExportEvent, KeyExportState> {
  final NekotonService _nekotonService;

  KeyExportBloc(this._nekotonService) : super(const KeyExportState.initial());

  @override
  Stream<KeyExportState> mapEventToState(KeyExportEvent event) async* {
    yield* event.when(
      exportKey: (
        String publicKey,
        String password,
      ) async* {
        try {
          final key = _nekotonService.keys.firstWhere((e) => e.publicKey == publicKey);

          late final ExportKeyInput exportKeyInput;

          if (key.isLegacy) {
            exportKeyInput = EncryptedKeyPassword(
              publicKey: key.publicKey,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          } else {
            exportKeyInput = DerivedKeyExportParams(
              masterKey: key.masterKey,
              password: Password.explicit(
                password: password,
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
            throw UnimplementedError();
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyExportState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class KeyExportEvent with _$KeyExportEvent {
  const factory KeyExportEvent.exportKey({
    required String publicKey,
    required String password,
  }) = _ExportKey;
}

@freezed
class KeyExportState with _$KeyExportState {
  const factory KeyExportState.initial() = _Initial;

  const factory KeyExportState.success(List<String> phrase) = _Success;

  const factory KeyExportState.error(String info) = _Error;
}
