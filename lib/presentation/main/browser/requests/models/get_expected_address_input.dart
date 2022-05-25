import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'get_expected_address_input.freezed.dart';
part 'get_expected_address_input.g.dart';

@freezed
class GetExpectedAddressInput with _$GetExpectedAddressInput {
  const factory GetExpectedAddressInput({
    required String tvc,
    required String abi,
    int? workchain,
    String? publicKey,
    required TokensObject initParams,
  }) = _GetExpectedAddressInput;

  factory GetExpectedAddressInput.fromJson(Map<String, dynamic> json) => _$GetExpectedAddressInputFromJson(json);
}
