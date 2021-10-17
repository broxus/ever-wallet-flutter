import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../domain/blocs/biometry/biometry_password_data_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';

Future<bool> showRequestPermissionsDialog(
  BuildContext context, {
  required String origin,
  required List<Permission> permissions,
  required String address,
  required String publicKey,
}) async =>
    await showPlatformDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Theme(
        data: ThemeData(),
        child: PlatformAlertDialog(
          title: const Text('Grant permissions'),
          content: Text(
              '$origin requested permissions ${permissions.map((e) => describeEnum(e).capitalize).join(', ')} to use your account with address ${address.elipseAddress()} and public key ${publicKey.elipsePublicKey()}'),
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
  required String publicKey,
  required String recipient,
  required String amount,
  required bool bounce,
  required FunctionCall? payload,
  required KnownPayload? knownPayload,
}) async {
  final controller = TextEditingController();

  final bloc = getIt.get<BiometryPasswordDataBloc>();

  final password = await showPlatformDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
      bloc: context.watch<BiometryInfoBloc>(),
      builder: (context, biometryInfoState) => Theme(
        data: ThemeData(),
        child: PlatformAlertDialog(
          title: const Text('Send message'),
          content: Column(
            children: [
              Text(
                  '$origin wants to send message from ${sender.elipseAddress()} to ${recipient.elipseAddress()} with amount of $amount and bounce $bounce'),
              if (biometryInfoState.isAvailable && biometryInfoState.isEnabled)
                const Text('Press allow to use biometry')
              else ...[
                const Text('Enter your password to allow'),
                PlatformWidget(
                  cupertino: (_, __) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CupertinoTextField(
                      controller: controller,
                      autofocus: true,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  material: (_, __) => TextField(
                    controller: controller,
                    autofocus: true,
                    obscureText: true,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            PlatformDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Deny'),
            ),
            PlatformDialogAction(
              onPressed: () async {
                if (biometryInfoState.isAvailable && biometryInfoState.isEnabled) {
                  bloc.add(BiometryPasswordDataEvent.getKeyPassword(publicKey));

                  final readyState = await bloc.stream.firstWhere((e) => e.maybeWhen(
                        ready: (password) => true,
                        orElse: () => false,
                      ));

                  final password = readyState.maybeWhen(
                    ready: (password) => password,
                    orElse: () => null,
                  );

                  Navigator.of(context).pop(password);
                } else {
                  Navigator.of(context).pop(controller.text.isNotEmpty ? controller.text : null);
                }
              },
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: true,
              ),
              child: const Text('Allow'),
            ),
          ],
        ),
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 1), () async {
    controller.dispose();
    bloc.close();
  });

  return password;
}

Future<String?> showCallContractMethodDialog(
  BuildContext context, {
  required String origin,
  required String selectedPublicKey,
  required String repackedRecipient,
  required FunctionCall? payload,
}) async {
  final controller = TextEditingController();

  final bloc = getIt.get<BiometryPasswordDataBloc>();

  final password = await showPlatformDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
      bloc: context.watch<BiometryInfoBloc>(),
      builder: (context, biometryInfoState) => Theme(
        data: ThemeData(),
        child: PlatformAlertDialog(
          title: const Text('Send message'),
          content: Column(
            children: [
              Text(
                  '$origin wants to call contract method with public key ${selectedPublicKey.elipsePublicKey()} to recipient ${repackedRecipient.elipseAddress()}}'),
              if (biometryInfoState.isAvailable && biometryInfoState.isEnabled)
                const Text('Press allow to use biometry')
              else ...[
                const Text('Enter your password to allow'),
                PlatformWidget(
                  cupertino: (_, __) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CupertinoTextField(
                      controller: controller,
                      autofocus: true,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  material: (_, __) => TextField(
                    controller: controller,
                    autofocus: true,
                    obscureText: true,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            PlatformDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Deny'),
            ),
            PlatformDialogAction(
              onPressed: () async {
                if (biometryInfoState.isAvailable && biometryInfoState.isEnabled) {
                  bloc.add(BiometryPasswordDataEvent.getKeyPassword(selectedPublicKey));

                  final readyState = await bloc.stream.firstWhere((e) => e.maybeWhen(
                        ready: (password) => true,
                        orElse: () => false,
                      ));

                  final password = readyState.maybeWhen(
                    ready: (password) => password,
                    orElse: () => null,
                  );

                  Navigator.of(context).pop(password);
                } else {
                  Navigator.of(context).pop(controller.text.isNotEmpty ? controller.text : null);
                }
              },
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: true,
              ),
              child: const Text('Allow'),
            ),
          ],
        ),
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 1), () async {
    controller.dispose();
    bloc.close();
  });

  return password;
}
