import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_transaction_info/ton_wallet_transaction_info_modal_body.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showTonWalletTransactionInfo({
  required BuildContext context,
  required TonWalletTransactionWithData transactionWithData,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => TonWalletTransactionInfoModalBody(
        transactionWithData: transactionWithData,
      ),
    );
