import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/browser/send_message_modal/send_message_modal.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

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
