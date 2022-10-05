import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

Future<void> showEditCustodianLabelDialog({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AsyncValueStreamProvider<Map<String, String>>(
        create: (context) => context.read<KeysRepository>().labelsStream,
        builder: (context, child) {
          final publicKeysLabels = context.watch<AsyncValue<Map<String, String>>>().maybeWhen(
                ready: (value) => value,
                orElse: () => <String, String>{},
              );

          final controller = TextEditingController(text: publicKeysLabels[publicKey]);

          return UnfocusingGestureDetector(
            child: PlatformAlertDialog(
              title: Text(AppLocalizations.of(context)!.custodian_label),
              content: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: PlatformTextField(
                  controller: controller,
                  autocorrect: false,
                  hintText: '${AppLocalizations.of(context)!.enter_name}...',
                ),
              ),
              actions: [
                PlatformDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                PlatformDialogAction(
                  onPressed: () async {
                    context.read<KeysRepository>().renameKey(
                          publicKey: publicKey,
                          name: controller.text,
                        );

                    Future.delayed(const Duration(seconds: 3), () {
                      controller.dispose();
                    });

                    Navigator.of(context).pop();
                  },
                  cupertino: (_, __) => CupertinoDialogActionData(
                    isDefaultAction: true,
                  ),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        },
      ),
    );
