import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'confirm_transaction_info_page.dart';

Future<void> startConfirmTransactionFlow({
  required BuildContext context,
  required String address,
  required String publicKey,
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
          builder: (_) => ConfirmTransactionInfoPage(
            modalContext: context,
            address: address,
            publicKey: publicKey,
            transactionId: transactionId,
            destination: destination,
            amount: amount,
            comment: comment,
          ),
        ),
      ),
    );
