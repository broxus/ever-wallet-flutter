import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_full_contract_state_input.freezed.dart';
part 'get_full_contract_state_input.g.dart';

@freezed
class GetFullContractStateInput with _$GetFullContractStateInput {
  const factory GetFullContractStateInput({
    required String address,
  }) = _GetFullContractStateInput;

  factory GetFullContractStateInput.fromJson(Map<String, dynamic> json) => _$GetFullContractStateInputFromJson(json);
}
