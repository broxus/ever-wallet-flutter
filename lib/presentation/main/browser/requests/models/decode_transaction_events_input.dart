import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'decode_transaction_events_input.freezed.dart';
part 'decode_transaction_events_input.g.dart';

@freezed
class DecodeTransactionEventsInput with _$DecodeTransactionEventsInput {
  @JsonSerializable(explicitToJson: true)
  const factory DecodeTransactionEventsInput({
    required Transaction transaction,
    required String abi,
  }) = _DecodeTransactionEventsInput;

  factory DecodeTransactionEventsInput.fromJson(Map<String, dynamic> json) =>
      _$DecodeTransactionEventsInputFromJson(json);
}
