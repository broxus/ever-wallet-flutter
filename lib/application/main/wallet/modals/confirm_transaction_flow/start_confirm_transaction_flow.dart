import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/confirm_transaction_flow/confirm_transaction_info_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/confirm_transaction_flow/prepare_confirm_transaction_page.dart';
import 'package:flutter/material.dart';

Future<void> startConfirmTransactionFlow({
  required BuildContext context,
  required String address,
  required List<String> publicKeys,
  required String transactionId,
  required String destination,
  required String amount,
  required String? comment,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => publicKeys.length > 1
              ? PrepareConfirmTransactionPage(
                  modalContext: context,
                  address: address,
                  publicKeys: publicKeys,
                  transactionId: transactionId,
                  destination: destination,
                  amount: amount,
                  comment: comment,
                )
              : ConfirmTransactionInfoPage(
                  modalContext: context,
                  address: address,
                  publicKey: publicKeys.first,
                  transactionId: transactionId,
                  destination: destination,
                  amount: amount,
                ),
        ),
      ),
    );
