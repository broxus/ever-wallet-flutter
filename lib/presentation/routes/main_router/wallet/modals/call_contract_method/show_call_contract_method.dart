import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'call_contract_method_modal.dart';

Future<String?> showCallContractMethod({
  required BuildContext context,
  required String origin,
  required String publicKey,
  required String recipient,
  required FunctionCall? payload,
}) =>
    showPlatformModalBottomSheet<String>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => CallContractMethodModalBody(
            modalContext: context,
            origin: origin,
            publicKey: publicKey,
            recipient: recipient,
            payload: payload,
          ),
        ),
      ),
    );
