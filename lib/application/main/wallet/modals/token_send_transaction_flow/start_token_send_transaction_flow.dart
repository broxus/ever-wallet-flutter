import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_send_transaction_flow/prepare_token_transfer_page.dart';
import 'package:flutter/material.dart';

Future<void> startTokenSendTransactionFlow({
  required BuildContext context,
  required String owner,
  required String rootTokenContract,
  required List<String> publicKeys,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => PrepareTokenTransferPage(
            modalContext: context,
            owner: owner,
            rootTokenContract: rootTokenContract,
            publicKeys: publicKeys,
          ),
        ),
      ),
    );
