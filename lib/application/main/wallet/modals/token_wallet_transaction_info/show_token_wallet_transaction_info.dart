import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_wallet_transaction_info/token_wallet_transaction_info_modal_body.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showTokenWalletTransactionInfo({
  required BuildContext context,
  required TokenWalletTransactionWithData transactionWithData,
  required String currency,
  required int decimals,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TokenWalletTransactionInfoModalBody(
        transactionWithData: transactionWithData,
        currency: currency,
        decimals: decimals,
      ),
    );
