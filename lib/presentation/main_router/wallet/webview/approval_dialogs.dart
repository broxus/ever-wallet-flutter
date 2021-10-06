import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../design/design.dart';

Future<bool> showRequestPermissionsDialog(
  BuildContext context, {
  required String origin,
  required List<Permission> permissions,
  required String address,
  required String publicKey,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Theme(
        data: ThemeData(),
        child: PlatformAlertDialog(
          title: const Text('Grant permissions'),
          content: Text(
              '$origin requested permissions ${permissions.map((e) => describeEnum(e).capitalize).join(', ')} to use your account with address ${'${address.substring(0, 6)}...${address.substring(address.length - 4, address.length)}'} and public key ${'${publicKey.substring(0, 4)}...${publicKey.substring(publicKey.length - 4, publicKey.length)}'}'),
          actions: [
            PlatformDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Deny'),
            ),
            PlatformDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: true,
              ),
              child: const Text('Allow'),
            ),
          ],
        ),
      ),
    ) ??
    false;

Future<String?> showSendMessageDialog(
  BuildContext context, {
  required String origin,
  required String sender,
  required String recipient,
  required String amount,
  required bool bounce,
  required FunctionCall? payload,
  required KnownPayload? knownPayload,
}) async {
  final controller = TextEditingController(text: '');

  final password = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => Theme(
      data: ThemeData(),
      child: PlatformAlertDialog(
        title: const Text('Send message'),
        content: Column(
          children: [
            Text(
                '$origin wants to send message from ${'${sender.substring(0, 6)}...${sender.substring(sender.length - 4, sender.length)}'} to ${'${recipient.substring(0, 6)}...${recipient.substring(recipient.length - 4, recipient.length)}'} with amount of $amount and bounce $bounce'),
            const Text('Enter your password to allow'),
            PlatformWidget(
              cupertino: (_, __) => Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CupertinoTextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              material: (_, __) => TextField(
                controller: controller,
                autofocus: true,
              ),
            ),
          ],
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Deny'),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(controller.text.isNotEmpty ? controller.text : null),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 1), controller.dispose);

  return password;
}

Future<String?> showCallContractMethodDialog(
  BuildContext context, {
  required String origin,
  required String selectedPublicKey,
  required String repackedRecipient,
  required FunctionCall? payload,
}) async {
  final controller = TextEditingController(text: '');

  final password = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => Theme(
      data: ThemeData(),
      child: PlatformAlertDialog(
        title: const Text('Send message'),
        content: Column(
          children: [
            Text(
                '$origin wants to call contract method with public key ${'${selectedPublicKey.substring(0, 4)}...${selectedPublicKey.substring(selectedPublicKey.length - 4, selectedPublicKey.length)}'} to recipient ${'${repackedRecipient.substring(0, 4)}...${repackedRecipient.substring(repackedRecipient.length - 4, repackedRecipient.length)}'}'),
            const Text('Enter your password to allow'),
            PlatformWidget(
              cupertino: (_, __) => Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CupertinoTextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              material: (_, __) => TextField(
                controller: controller,
                autofocus: true,
              ),
            ),
          ],
        ),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Deny'),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(controller.text.isNotEmpty ? controller.text : null),
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 1), controller.dispose);

  return password;
}
