import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_transaction_input.freezed.dart';
part 'get_transaction_input.g.dart';

@freezed
class GetTransactionInput with _$GetTransactionInput {
  const factory GetTransactionInput({
    required String hash,
  }) = _GetTransactionInput;

  factory GetTransactionInput.fromJson(Map<String, dynamic> json) => _$GetTransactionInputFromJson(json);
}
