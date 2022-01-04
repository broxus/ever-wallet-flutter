import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'prepare_token_transfer_page.dart';

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
