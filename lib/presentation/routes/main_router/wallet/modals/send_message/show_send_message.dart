import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'send_message_modal.dart';

Future<String?> showSendMessage({
  required BuildContext context,
  required String origin,
  required String sender,
  required String publicKey,
  required String recipient,
  required String amount,
  required bool bounce,
  required FunctionCall? payload,
  required KnownPayload? knownPayload,
}) =>
    showPlatformModalBottomSheet<String>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => SendMessageModalBody(
            modalContext: context,
            origin: origin,
            sender: sender,
            publicKey: publicKey,
            recipient: recipient,
            amount: amount,
            bounce: bounce,
            payload: payload,
            knownPayload: knownPayload,
          ),
        ),
      ),
    );
