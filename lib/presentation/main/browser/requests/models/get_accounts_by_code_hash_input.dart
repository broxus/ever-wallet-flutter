import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_accounts_by_code_hash_input.freezed.dart';
part 'get_accounts_by_code_hash_input.g.dart';

@freezed
class GetAccountsByCodeHashInput with _$GetAccountsByCodeHashInput {
  const factory GetAccountsByCodeHashInput({
    required String codeHash,
    String? continuation,
    int? limit,
  }) = _GetAccountsByCodeHashInput;

  factory GetAccountsByCodeHashInput.fromJson(Map<String, dynamic> json) => _$GetAccountsByCodeHashInputFromJson(json);
}
