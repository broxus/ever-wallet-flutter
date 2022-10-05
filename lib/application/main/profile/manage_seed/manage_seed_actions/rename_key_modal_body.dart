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

class RenameKeyModalBody extends StatefulWidget {
  final String publicKey;

  const RenameKeyModalBody({
    super.key,
    required this.publicKey,
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

                        await context
                            .read<KeysRepository>()
                            .renameKey(publicKey: widget.publicKey, name: value.text.trim());

                        if (!mounted) return;

                        await showFlushbar(
                          context,
                          message: localization.seed_phrase_renamed,
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
              text: localization.rename,
            ),
          )
        ],
      ),
    );
  }
}
