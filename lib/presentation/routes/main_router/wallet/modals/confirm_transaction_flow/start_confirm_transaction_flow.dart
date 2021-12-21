import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'prepare_confirm_transaction_page.dart';

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
          builder: (_) => PrepareConfirmTransactionPage(
            modalContext: context,
            address: address,
            publicKeys: publicKeys,
            transactionId: transactionId,
            destination: destination,
            amount: amount,
            comment: comment,
          ),
        ),
      ),
    );
