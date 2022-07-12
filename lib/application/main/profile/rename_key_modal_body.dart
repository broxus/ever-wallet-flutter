import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/crystal_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

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
            const Gap(20),
            CrystalTextFormField(
              controller: controller,
              autofocus: true,
              formatters: [LengthLimitingTextInputFormatter(50)],
              hintText: AppLocalizations.of(context)!.name,
            ),
            const Gap(24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => CustomElevatedButton(
                onPressed: value.text.isEmpty
                    ? null
                    : () async {
                        try {
                          Navigator.of(context).pop();

                          await context.read<KeysRepository>().renameKey(
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

                          await showFlushbar(
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
