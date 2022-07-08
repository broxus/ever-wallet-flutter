import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_boc_hash_output.freezed.dart';
part 'get_boc_hash_output.g.dart';

@freezed
class GetBocHashOutput with _$GetBocHashOutput {
  const factory GetBocHashOutput({
    required String hash,
  }) = _GetBocHashOutput;

  factory GetBocHashOutput.fromJson(Map<String, dynamic> json) => _$GetBocHashOutputFromJson(json);
}
