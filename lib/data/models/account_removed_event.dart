import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'account_removed_event.freezed.dart';

@freezed
class AccountRemovedEvent with _$AccountRemovedEvent {
  const factory AccountRemovedEvent(AssetsList account) = _AccountRemovedEvent;
}
