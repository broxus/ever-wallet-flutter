import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'prepare_transfer_page.dart';

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
