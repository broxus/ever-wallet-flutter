import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'get_transactions_input.freezed.dart';
part 'get_transactions_input.g.dart';

@freezed
class GetTransactionsInput with _$GetTransactionsInput {
  @JsonSerializable(explicitToJson: true)
  const factory GetTransactionsInput({
    required String address,
    TransactionId? continuation,
    int? limit,
  }) = _GetTransactionsInput;

  factory GetTransactionsInput.fromJson(Map<String, dynamic> json) => _$GetTransactionsInputFromJson(json);
}
