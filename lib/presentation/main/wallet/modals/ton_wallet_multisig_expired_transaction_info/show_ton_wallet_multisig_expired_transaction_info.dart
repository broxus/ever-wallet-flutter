import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'ton_wallet_multisig_expired_transaction_info.dart';

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
