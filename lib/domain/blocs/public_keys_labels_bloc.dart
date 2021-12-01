import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../repositories/public_keys_labels_repository.dart';

part 'public_keys_labels_bloc.freezed.dart';

@injectable
class PublicKeysLabelsBloc extends Bloc<_Event, Map<String, String>> {
  final PublicKeysLabelsRepository _publicKeysLabelsRepository;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;

  PublicKeysLabelsBloc(this._publicKeysLabelsRepository) : super({}) {
    _streamSubscription = _publicKeysLabelsRepository.labelsStream.listen((event) => add(_LocalEvent.update(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<Map<String, String>> mapEventToState(_Event event) async* {
    try {
      if (event is _Save) {
        await _publicKeysLabelsRepository.save(
          publicKey: event.publicKey,
          label: event.label,
        );
      } else if (event is _Remove) {
        await _publicKeysLabelsRepository.remove(event.publicKey);
      } else if (event is _Update) {
        yield event.labels;
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update(Map<String, String> labels) = _Update;
}

@freezed
class PublicKeysLabelsEvent extends _Event with _$PublicKeysLabelsEvent {
  const factory PublicKeysLabelsEvent.save({
    required String publicKey,
    required String label,
  }) = _Save;

  const factory PublicKeysLabelsEvent.remove(String publicKey) = _Remove;
}
