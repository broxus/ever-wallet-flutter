import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RenameModalBodyType { key, seed }

class RenameKeyModalBody extends StatefulWidget {
  final String publicKey;
  final RenameModalBodyType type;

  const RenameKeyModalBody({
    super.key,
    required this.publicKey,
    required this.type,
  });

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
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          BorderedInput(
            controller: controller,
            autofocus: true,
            formatters: [LengthLimitingTextInputFormatter(50)],
            label: localization.name,
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
            cursorColor: ColorsRes.text,
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => PrimaryElevatedButton(
              onPressed: value.text.isEmpty
                  ? null
                  : () async {
                      try {
                        Navigator.of(context).pop();
                        String flushTitle;

                        switch (widget.type) {
                          case RenameModalBodyType.key:
                            await context
                                .read<KeysRepository>()
                                .renameKey(publicKey: widget.publicKey, name: value.text.trim());
                            flushTitle = localization.key_renamed;
                            break;
                          case RenameModalBodyType.seed:
                            await context
                                .read<KeysRepository>()
                                .renameSeed(publicKey: widget.publicKey, name: value.text.trim());
                            flushTitle = localization.seed_phrase_renamed;
                            break;
                        }

                        if (!mounted) return;

                        await showFlushbar(context, message: flushTitle);
                      } catch (err, st) {
                        logger.e(err, err, st);

                        if (!mounted) return;

                        await showErrorFlushbar(
                          context,
                          message: (err as Exception).toUiMessage(),
                        );
                      }
                    },
              text: localization.rename,
            ),
          )
        ],
      ),
    );
  }
}
