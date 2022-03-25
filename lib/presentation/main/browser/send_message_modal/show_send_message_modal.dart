import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'send_message_modal.dart';

Future<Tuple2<String, String>?> showSendMessageModal({
  required BuildContext context,
  required String origin,
  required String sender,
  required List<String> publicKeys,
  required String recipient,
  required String amount,
  required bool bounce,
  required FunctionCall? payload,
  required KnownPayload? knownPayload,
}) =>
    showPlatformModalBottomSheet<Tuple2<String, String>>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => SendMessagePage(
            modalContext: context,
            origin: origin,
            sender: sender,
            publicKeys: publicKeys,
            recipient: recipient,
            amount: amount,
            bounce: bounce,
            payload: payload,
            knownPayload: knownPayload,
          ),
        ),
      ),
    );
