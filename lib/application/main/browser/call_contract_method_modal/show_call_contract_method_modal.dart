import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/browser/call_contract_method_modal/call_contract_method_page.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<String?> showCallContractMethodModal({
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
          builder: (_) => CallContractMethodPage(
            modalContext: context,
            origin: origin,
            publicKey: publicKey,
            recipient: recipient,
            payload: payload,
          ),
        ),
      ),
    );
