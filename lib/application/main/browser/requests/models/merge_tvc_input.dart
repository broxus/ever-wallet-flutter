import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_tvc_input.freezed.dart';
part 'merge_tvc_input.g.dart';

@freezed
class MergeTvcInput with _$MergeTvcInput {
  const factory MergeTvcInput({
    required String code,
    required String data,
  }) = _MergeTvcInput;

  factory MergeTvcInput.fromJson(Map<String, dynamic> json) => _$MergeTvcInputFromJson(json);
}
