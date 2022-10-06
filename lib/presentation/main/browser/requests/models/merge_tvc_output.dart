import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_tvc_output.freezed.dart';
part 'merge_tvc_output.g.dart';

@freezed
class MergeTvcOutput with _$MergeTvcOutput {
  const factory MergeTvcOutput({
    required String tvc,
  }) = _MergeTvcOutput;

  factory MergeTvcOutput.fromJson(Map<String, dynamic> json) => _$MergeTvcOutputFromJson(json);
}
