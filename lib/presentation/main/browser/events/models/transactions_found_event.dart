import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transactions_found_event.freezed.dart';
part 'transactions_found_event.g.dart';

@freezed
class TransactionsFoundEvent with _$TransactionsFoundEvent {
  @JsonSerializable(explicitToJson: true)
  const factory TransactionsFoundEvent({
    required String address,
    required List<Transaction> transactions,
    required TransactionsBatchInfo info,
  }) = _TransactionsFoundEvent;

  factory TransactionsFoundEvent.fromJson(Map<String, dynamic> json) => _$TransactionsFoundEventFromJson(json);
}
