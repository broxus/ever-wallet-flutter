import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'contract_state_changed_event.freezed.dart';
part 'contract_state_changed_event.g.dart';

@freezed
class ContractStateChangedEvent with _$ContractStateChangedEvent {
  const factory ContractStateChangedEvent({
    required String address,
    required ContractState state,
  }) = _ContractStateChangedEvent;

  factory ContractStateChangedEvent.fromJson(Map<String, dynamic> json) =>
      _$ContractStateChangedEventFromJson(json);
}
