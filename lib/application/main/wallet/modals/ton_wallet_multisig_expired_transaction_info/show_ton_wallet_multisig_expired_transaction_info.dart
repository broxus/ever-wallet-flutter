import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_expired_transaction_info/ton_wallet_multisig_expired_transaction_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_expired_transaction.dart';
import 'package:flutter/material.dart';

Future<void> showTonWalletMultisigExpiredTransactionInfo({
  required BuildContext context,
  required TonWalletMultisigExpiredTransaction transaction,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) =>
          TonWalletMultisigExpiredTransactionInfoModalBody(transaction: transaction),
    );
