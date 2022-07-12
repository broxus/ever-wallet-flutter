import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_tvc_input.freezed.dart';
part 'split_tvc_input.g.dart';

@freezed
class SplitTvcInput with _$SplitTvcInput {
  const factory SplitTvcInput({
    required String tvc,
  }) = _SplitTvcInput;

  factory SplitTvcInput.fromJson(Map<String, dynamic> json) => _$SplitTvcInputFromJson(json);
}
