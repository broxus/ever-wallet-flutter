import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/prepare_transfer_page.dart';
import 'package:flutter/material.dart';

Future<void> startSendTransactionFlow({
  required BuildContext context,
  required String address,
  required List<String> publicKeys,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => PrepareTransferPage(
            modalContext: context,
            address: address,
            publicKeys: publicKeys,
          ),
        ),
      ),
    );
