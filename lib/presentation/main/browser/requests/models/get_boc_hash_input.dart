import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_boc_hash_input.freezed.dart';
part 'get_boc_hash_input.g.dart';

@freezed
class GetBocHashInput with _$GetBocHashInput {
  const factory GetBocHashInput({
    required String boc,
  }) = _GetBocHashInput;

  factory GetBocHashInput.fromJson(Map<String, dynamic> json) => _$GetBocHashInputFromJson(json);
}
