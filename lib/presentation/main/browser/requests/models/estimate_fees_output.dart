import 'package:freezed_annotation/freezed_annotation.dart';

part 'estimate_fees_output.freezed.dart';
part 'estimate_fees_output.g.dart';

@freezed
class EstimateFeesOutput with _$EstimateFeesOutput {
  const factory EstimateFeesOutput({
    required String fees,
  }) = _EstimateFeesOutput;

  factory EstimateFeesOutput.fromJson(Map<String, dynamic> json) => _$EstimateFeesOutputFromJson(json);
}
