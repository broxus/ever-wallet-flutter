import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_transaction_info/ton_wallet_multisig_transaction_info.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showTonWalletMultisigTransactionInfo({
  required BuildContext context,
  required TonWalletTransactionWithData transactionWithData,
  required String creator,
  required List<String> confirmations,
  required List<String> custodians,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonWalletMultisigTransactionInfoModalBody(
        transactionWithData: transactionWithData,
        creator: creator,
        confirmations: confirmations,
        custodians: custodians,
      ),
    );
