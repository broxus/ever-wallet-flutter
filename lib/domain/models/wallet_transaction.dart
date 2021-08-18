import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'wallet_transaction.freezed.dart';

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction.ordinary({
    required String hash,
    TransactionId? prevTransId,
    required String totalFees,
    required String address,
    required String value,
    required DateTime createdAt,
    required bool isOutgoing,
    required String currency,
    required String feesCurrency,
    String? data,
  }) = _Ordinary;

  const factory WalletTransaction.sent({
    required String hash,
    TransactionId? prevTransId,
    required String totalFees,
    required String address,
    required String value,
    required DateTime createdAt,
    required bool isOutgoing,
    required String currency,
    required String feesCurrency,
  }) = _Sent;

  const factory WalletTransaction.expired({
    required String hash,
    TransactionId? prevTransId,
    required String totalFees,
    required String address,
    required String value,
    required DateTime createdAt,
    required bool isOutgoing,
    required String currency,
    required String feesCurrency,
  }) = _Expired;
}
