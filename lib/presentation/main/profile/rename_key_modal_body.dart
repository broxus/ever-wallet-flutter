import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../injection.dart';
import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../logger.dart';
import '../../../data/extensions.dart';
import '../../common/widgets/crystal_flushbar.dart';
import '../../common/widgets/crystal_text_form_field.dart';
import '../../common/widgets/custom_elevated_button.dart';

class RenameKeyModalBody extends StatefulWidget {
  final String publicKey;

  const RenameKeyModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  _RenameKeyModalBodyState createState() => _RenameKeyModalBodyState();
}

class _RenameKeyModalBodyState extends State<RenameKeyModalBody> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            CrystalTextFormField(
              controller: controller,
              autofocus: true,
              formatters: [LengthLimitingTextInputFormatter(50)],
              hintText: AppLocalizations.of(context)!.name,
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => CustomElevatedButton(
                onPressed: value.text.isEmpty
                    ? null
                    : () async {
                        try {
                          context.router.navigatorKey.currentState?.pop();

                          await getIt.get<KeysRepository>().renameKey(
                                publicKey: widget.publicKey,
                                name: value.text,
                              );

                          if (!mounted) return;

                          await showFlushbar(
                            context,
                            message: AppLocalizations.of(context)!.seed_phrase_renamed,
                          );
                        } catch (err, st) {
                          logger.e(err, err, st);

                          if (!mounted) return;

                          await showErrorFlushbar(
                            context,
                            message: (err as Exception).toUiMessage(),
                          );
                        }
                      },
                text: AppLocalizations.of(context)!.rename,
              ),
            )
          ],
        ),
      );
}
