import 'package:collection/collection.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_expired_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_multisig_expired_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_multisig_pending_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_multisig_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_pending_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/ton_wallet_transaction_holder.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

List<StatelessWidget> mapTonWalletTransactionsToWidgets({
  required Duration timeForConfirmation,
  required TonWalletInfo tonWalletInfo,
  required List<TonWalletTransactionWithData> transactions,
  required List<PendingTransaction> pendingTransactions,
  required List<PendingTransaction> expiredTransactions,
  required List<MultisigPendingTransaction> multisigPendingTransactions,
}) {
  final ordinary = transactions
      .where(
        (e) =>
            e.data?.maybeWhen(
              walletInteraction: (info) => info.method.maybeWhen(
                multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                  send: (multisigSendTransaction) => true,
                  orElse: () => false,
                ),
                orElse: () => true,
              ),
              orElse: () => true,
            ) ??
            true,
      )
      .map(
        (e) => Tuple2(
          e.transaction.createdAt,
          TonWalletTransactionHolder(
            transactionWithData: e,
            walletAddress: tonWalletInfo.address,
          ),
        ),
      );

  final pending = pendingTransactions.map(
    (e) => Tuple2(
      e.expireAt,
      TonWalletPendingTransactionHolder(
        pendingTransaction: e,
        walletAddress: tonWalletInfo.address,
      ),
    ),
  );

  final expired = expiredTransactions.map(
    (e) => Tuple2(
      e.expireAt,
      TonWalletExpiredTransactionHolder(
        pendingTransaction: e,
        walletAddress: tonWalletInfo.address,
      ),
    ),
  );

  final multisigOrdinary = transactions
      .where(
    (e) =>
        e.data != null &&
        e.data!.maybeWhen(
          walletInteraction: (info) => info.method.maybeWhen(
            multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
              submit: (multisigSubmitTransaction) {
                final submitTransactionId = multisigSubmitTransaction.transId;

                return multisigPendingTransactions.every((e) => e.id != submitTransactionId) &&
                    transactions
                        .where(
                          (e) =>
                              e.data != null &&
                              e.data!.maybeWhen(
                                walletInteraction: (info) => info.method.maybeWhen(
                                  multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                                    submit: (multisigSubmitTransaction) =>
                                        multisigSubmitTransaction.transId == submitTransactionId,
                                    confirm: (multisigConfirmTransaction) =>
                                        multisigConfirmTransaction.transactionId ==
                                        submitTransactionId,
                                    orElse: () => false,
                                  ),
                                  orElse: () => false,
                                ),
                                orElse: () => false,
                              ),
                        )
                        .any((e) => e.transaction.outMessages.isNotEmpty);
              },
              orElse: () => false,
            ),
            orElse: () => false,
          ),
          orElse: () => false,
        ),
  )
      .map(
    (e) {
      final multisigSubmitTransaction = e.data!.maybeWhen(
        walletInteraction: (info) => info.method.maybeWhen(
          multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
            submit: (multisigSubmitTransaction) => multisigSubmitTransaction,
            orElse: () => null,
          ),
          orElse: () => null,
        ),
        orElse: () => null,
      )!;

      final transactionId = multisigSubmitTransaction.transId;

      final confirmations = transactions
          .where(
            (e) =>
                e.data != null &&
                e.data!.maybeWhen(
                  walletInteraction: (info) => info.method.maybeWhen(
                    multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                      submit: (multisigSubmitTransaction) =>
                          multisigSubmitTransaction.transId == transactionId,
                      confirm: (multisigConfirmTransaction) =>
                          multisigConfirmTransaction.transactionId == transactionId,
                      orElse: () => false,
                    ),
                    orElse: () => false,
                  ),
                  orElse: () => false,
                ),
          )
          .map(
            (e) => e.data?.maybeWhen(
              walletInteraction: (info) => info.method.maybeWhen(
                multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                  submit: (multisigSubmitTransaction) => multisigSubmitTransaction.custodian,
                  confirm: (multisigConfirmTransaction) => multisigConfirmTransaction.custodian,
                  orElse: () => null,
                ),
                orElse: () => null,
              ),
              orElse: () => null,
            ),
          )
          .whereNotNull()
          .toList();

      return Tuple2(
        e.transaction.createdAt,
        TonWalletMultisigTransactionHolder(
          transactionWithData: e,
          creator: multisigSubmitTransaction.custodian,
          confirmations: confirmations,
          walletAddress: tonWalletInfo.address,
          custodians: tonWalletInfo.custodians ?? [],
        ),
      );
    },
  );

  final multisigPending = transactions
      .where(
    (e) =>
        e.data != null &&
        e.data!.maybeWhen(
          walletInteraction: (info) => info.method.maybeWhen(
            multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
              submit: (multisigSubmitTransaction) =>
                  multisigPendingTransactions.any((e) => e.id == multisigSubmitTransaction.transId),
              orElse: () => false,
            ),
            orElse: () => false,
          ),
          orElse: () => false,
        ),
  )
      .map(
    (e) {
      final multisigPendingTransaction = multisigPendingTransactions.firstWhere(
        (el) =>
            el.id ==
            e.data?.maybeWhen(
              walletInteraction: (info) => info.method.maybeWhen(
                multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                  submit: (multisigSubmitTransaction) => multisigSubmitTransaction.transId,
                  orElse: () => null,
                ),
                orElse: () => null,
              ),
              orElse: () => null,
            ),
      );

      return Tuple2(
        e.transaction.createdAt,
        TonWalletMultisigPendingTransactionHolder(
          transactionWithData: e,
          multisigPendingTransaction: multisigPendingTransaction,
          walletAddress: tonWalletInfo.address,
          walletPublicKey: tonWalletInfo.publicKey,
          walletType: tonWalletInfo.walletType,
          custodians: tonWalletInfo.custodians ?? [],
          details: tonWalletInfo.details,
        ),
      );
    },
  );

  final multisigExpired = transactions
      .where(
    (e) =>
        e.data != null &&
        e.data!.maybeWhen(
          walletInteraction: (info) => info.method.maybeWhen(
            multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
              submit: (multisigSubmitTransaction) {
                final submitTransactionId = multisigSubmitTransaction.transId;

                return multisigPendingTransactions.every((e) => e.id != submitTransactionId) &&
                    transactions
                        .where(
                          (e) =>
                              e.data != null &&
                              e.data!.maybeWhen(
                                walletInteraction: (info) => info.method.maybeWhen(
                                  multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                                    submit: (multisigSubmitTransaction) =>
                                        multisigSubmitTransaction.transId == submitTransactionId,
                                    confirm: (multisigConfirmTransaction) =>
                                        multisigConfirmTransaction.transactionId ==
                                        submitTransactionId,
                                    orElse: () => false,
                                  ),
                                  orElse: () => false,
                                ),
                                orElse: () => false,
                              ),
                        )
                        .every((e) => e.transaction.outMessages.isEmpty);
              },
              orElse: () => false,
            ),
            orElse: () => false,
          ),
          orElse: () => false,
        ),
  )
      .map(
    (e) {
      final multisigSubmitTransaction = e.data!.maybeWhen(
        walletInteraction: (info) => info.method.maybeWhen(
          multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
            submit: (multisigSubmitTransaction) => multisigSubmitTransaction,
            orElse: () => null,
          ),
          orElse: () => null,
        ),
        orElse: () => null,
      )!;

      final transactionId = multisigSubmitTransaction.transId;

      final confirmations = transactions
          .where(
            (e) =>
                e.data != null &&
                e.data!.maybeWhen(
                  walletInteraction: (info) => info.method.maybeWhen(
                    multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                      submit: (multisigSubmitTransaction) =>
                          multisigSubmitTransaction.transId == transactionId,
                      confirm: (multisigConfirmTransaction) =>
                          multisigConfirmTransaction.transactionId == transactionId,
                      orElse: () => false,
                    ),
                    orElse: () => false,
                  ),
                  orElse: () => false,
                ),
          )
          .map(
            (e) => e.data?.maybeWhen(
              walletInteraction: (info) => info.method.maybeWhen(
                multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                  submit: (multisigSubmitTransaction) => multisigSubmitTransaction.custodian,
                  confirm: (multisigConfirmTransaction) => multisigConfirmTransaction.custodian,
                  orElse: () => null,
                ),
                orElse: () => null,
              ),
              orElse: () => null,
            ),
          )
          .whereNotNull()
          .toList();

      return Tuple2(
        e.transaction.createdAt,
        TonWalletMultisigExpiredTransactionHolder(
          transactionWithData: e,
          creator: multisigSubmitTransaction.custodian,
          confirmations: confirmations,
          walletAddress: tonWalletInfo.address,
          walletPublicKey: tonWalletInfo.publicKey,
          walletType: tonWalletInfo.walletType,
          custodians: tonWalletInfo.custodians ?? [],
        ),
      );
    },
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
