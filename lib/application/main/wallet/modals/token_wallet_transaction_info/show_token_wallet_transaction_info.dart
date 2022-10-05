import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_wallet_transaction_info/token_wallet_transaction_info_modal_body.dart';
import 'package:ever_wallet/data/models/token_wallet_ordinary_transaction.dart';
import 'package:flutter/material.dart';

Future<void> showTokenWalletTransactionInfo({
  required BuildContext context,
  required TokenWalletOrdinaryTransaction transaction,
  required String currency,
  required int decimals,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TokenWalletTransactionInfoModalBody(
        transaction: transaction,
        currency: currency,
        decimals: decimals,
      ),
    );
