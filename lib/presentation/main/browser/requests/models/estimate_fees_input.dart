import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'estimate_fees_input.freezed.dart';
part 'estimate_fees_input.g.dart';

@freezed
class EstimateFeesInput with _$EstimateFeesInput {
  @JsonSerializable(explicitToJson: true)
  const factory EstimateFeesInput({
    required String sender,
    required String recipient,
    required String amount,
    FunctionCall? payload,
  }) = _EstimateFeesInput;

  factory EstimateFeesInput.fromJson(Map<String, dynamic> json) => _$EstimateFeesInputFromJson(json);
}
