import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_expired_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_multisig_expired_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_multisig_pending_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_multisig_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_pending_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_transaction_holder.dart';
import 'package:ever_wallet/data/models/ton_wallet_expired_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_expired_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_pending_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_pending_transaction.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

List<StatelessWidget> mapTonWalletTransactionsToWidgets({
  required List<TonWalletOrdinaryTransaction> ordinaryTransactions,
  required List<TonWalletPendingTransaction> pendingTransactions,
  required List<TonWalletExpiredTransaction> expiredTransactions,
  required List<TonWalletMultisigOrdinaryTransaction> multisigOrdinaryTransactions,
  required List<TonWalletMultisigPendingTransaction> multisigPendingTransactions,
  required List<TonWalletMultisigExpiredTransaction> multisigExpiredTransactions,
}) {
  final ordinary = ordinaryTransactions.map(
    (e) => Tuple2(
      e.date,
      TonWalletTransactionHolder(transaction: e),
    ),
  );

  final pending = pendingTransactions.map(
    (e) => Tuple2(
      e.expireAt,
      TonWalletPendingTransactionHolder(transaction: e),
    ),
  );

  final expired = expiredTransactions.map(
    (e) => Tuple2(
      e.expireAt,
      TonWalletExpiredTransactionHolder(transaction: e),
    ),
  );

  final multisigOrdinary = multisigOrdinaryTransactions.map(
    (e) => Tuple2(
      e.date,
      TonWalletMultisigTransactionHolder(transaction: e),
    ),
  );

  final multisigPending = multisigPendingTransactions.map(
    (e) => Tuple2(
      e.date,
      TonWalletMultisigPendingTransactionHolder(transaction: e),
    ),
  );

  final multisigExpired = multisigExpiredTransactions.map(
    (e) => Tuple2(
      e.date,
      TonWalletMultisigExpiredTransactionHolder(transaction: e),
    ),
  );

  final sorted = [
    ...ordinary,
    ...pending,
    ...expired,
    ...multisigOrdinary,
    ...multisigPending,
    ...multisigExpired,
  ]..sort((a, b) => b.item1.compareTo(a.item1));

  return sorted.map((e) => e.item2).toList();
}
