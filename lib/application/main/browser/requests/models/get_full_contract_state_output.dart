import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'get_full_contract_state_output.freezed.dart';
part 'get_full_contract_state_output.g.dart';

@freezed
class GetFullContractStateOutput with _$GetFullContractStateOutput {
  const factory GetFullContractStateOutput({
    @JsonKey(includeIfNull: false) FullContractState? state,
  }) = _GetFullContractStateOutput;

  factory GetFullContractStateOutput.fromJson(Map<String, dynamic> json) =>
      _$GetFullContractStateOutputFromJson(json);
}
