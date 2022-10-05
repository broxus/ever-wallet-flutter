import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'key_added_event.freezed.dart';

@freezed
class KeyAddedEvent with _$KeyAddedEvent {
  const factory KeyAddedEvent(KeyStoreEntry key) = _KeyAddedEvent;
}
