import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'prepare_token_transfer_page.dart';

Future<void> startTokenSendTransactionFlow({
  required BuildContext context,
  required String owner,
  required String rootTokenContract,
}) =>
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => PrepareTokenTransferPage(
            modalContext: context,
            owner: owner,
            rootTokenContract: rootTokenContract,
          ),
        ),
      ),
    );
