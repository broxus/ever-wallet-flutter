import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../../domain/blocs/public_keys_labels_bloc.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';

Future<void> showEditCustodianLabelDialog({
  required BuildContext context,
  required String publicKey,
}) =>
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController(text: context.read<PublicKeysLabelsBloc>().state[publicKey]);

        return UnfocusingGestureDetector(
          child: PlatformAlertDialog(
            title: const Text("Custodian's label"),
            content: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PlatformTextField(
                controller: controller,
                autocorrect: false,
                hintText: 'Enter name...',
              ),
            ),
            actions: [
              PlatformDialogAction(
                onPressed: () => context.router.pop(),
                child: const Text('Cancel'),
              ),
              PlatformDialogAction(
                onPressed: () async {
                  context.read<PublicKeysLabelsBloc>().add(
                        PublicKeysLabelsEvent.save(
                          publicKey: publicKey,
                          label: controller.text,
                        ),
                      );

                  Future.delayed(const Duration(seconds: 3), () {
                    controller.dispose();
                  });

                  context.router.pop();
                },
                cupertino: (_, __) => CupertinoDialogActionData(
                  isDefaultAction: true,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      barrierDismissible: true,
    );
