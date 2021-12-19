import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'ton_wallet_multisig_pending_transaction_info.dart';

Future<void> tonWalletMultisigPendingTransactionInfo({
  required BuildContext context,
  required TonWalletTransactionWithData transactionWithData,
  required MultisigPendingTransaction? multisigPendingTransaction,
  required String? walletAddress,
  required WalletType? walletType,
  required List<String>? custodians,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonWalletMultisigPendingTransactionInfoModalBody(
        transactionWithData: transactionWithData,
        multisigPendingTransaction: multisigPendingTransaction,
        walletAddress: walletAddress,
        walletType: walletType,
        custodians: custodians,
      ),
    );
