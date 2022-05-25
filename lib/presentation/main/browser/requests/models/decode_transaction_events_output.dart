import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'decode_transaction_events_output.freezed.dart';
part 'decode_transaction_events_output.g.dart';

@freezed
class DecodeTransactionEventsOutput with _$DecodeTransactionEventsOutput {
  @JsonSerializable(explicitToJson: true)
  const factory DecodeTransactionEventsOutput({
    required List<DecodedTransactionEvent> events,
  }) = _DecodeTransactionEventsOutput;

  factory DecodeTransactionEventsOutput.fromJson(Map<String, dynamic> json) =>
      _$DecodeTransactionEventsOutputFromJson(json);
}
