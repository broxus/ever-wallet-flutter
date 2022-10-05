import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_transaction_info/ton_wallet_transaction_info_modal_body.dart';
import 'package:ever_wallet/data/models/ton_wallet_ordinary_transaction.dart';
import 'package:flutter/material.dart';

Future<void> showTonWalletTransactionInfo({
  required BuildContext context,
  required TonWalletOrdinaryTransaction transaction,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonWalletTransactionInfoModalBody(
        transaction: transaction,
      ),
    );
