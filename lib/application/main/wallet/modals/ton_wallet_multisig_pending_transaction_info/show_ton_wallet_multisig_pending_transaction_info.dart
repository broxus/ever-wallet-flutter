import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_pending_transaction_info/ton_wallet_multisig_pending_transaction_info.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showTonWalletMultisigPendingTransactionInfo({
  required BuildContext context,
  required TonWalletTransactionWithData transactionWithData,
  required MultisigPendingTransaction? multisigPendingTransaction,
  required String walletAddress,
  required String walletPublicKey,
  required WalletType walletType,
  required List<String> custodians,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonWalletMultisigPendingTransactionInfoModalBody(
        transactionWithData: transactionWithData,
        multisigPendingTransaction: multisigPendingTransaction,
        walletAddress: walletAddress,
        walletPublicKey: walletPublicKey,
        walletType: walletType,
        custodians: custodians,
      ),
    );
