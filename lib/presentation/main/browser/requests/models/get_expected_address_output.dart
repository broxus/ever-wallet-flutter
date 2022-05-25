import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_expected_address_output.freezed.dart';
part 'get_expected_address_output.g.dart';

@freezed
class GetExpectedAddressOutput with _$GetExpectedAddressOutput {
  const factory GetExpectedAddressOutput({
    required String address,
  }) = _GetExpectedAddressOutput;

  factory GetExpectedAddressOutput.fromJson(Map<String, dynamic> json) => _$GetExpectedAddressOutputFromJson(json);
}
