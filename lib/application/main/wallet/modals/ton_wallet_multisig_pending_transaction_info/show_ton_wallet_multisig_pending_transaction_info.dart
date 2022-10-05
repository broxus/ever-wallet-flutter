import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_pending_transaction_info/ton_wallet_multisig_pending_transaction_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_pending_transaction.dart';
import 'package:flutter/material.dart';

Future<void> showTonWalletMultisigPendingTransactionInfo({
  required BuildContext context,
  required TonWalletMultisigPendingTransaction transaction,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) =>
          TonWalletMultisigPendingTransactionInfoModalBody(transaction: transaction),
    );
