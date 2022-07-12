import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_expired_transaction_info/ton_wallet_multisig_expired_transaction_info.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showTonWalletMultisigExpiredTransactionInfo({
  required BuildContext context,
  required TonWalletTransactionWithData transactionWithData,
  required String creator,
  required List<String> confirmations,
  required String walletAddress,
  required List<String> custodians,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonWalletMultisigExpiredTransactionInfoModalBody(
        transactionWithData: transactionWithData,
        creator: creator,
        confirmations: confirmations,
        walletAddress: walletAddress,
        custodians: custodians,
      ),
    );
