import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'ton_wallet_transaction_info_modal_body.dart';

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
