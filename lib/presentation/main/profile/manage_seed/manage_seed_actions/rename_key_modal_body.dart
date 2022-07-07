import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../../injection.dart';
import '../../../../../../../data/repositories/keys_repository.dart';
import '../../../../../../../injection.dart';
import '../../../../../../data/repositories/keys_repository.dart';
import '../../../../../../logger.dart';
import '../../../../../data/extensions.dart';
import '../../../../common/general/button/primary_elevated_button.dart';
import '../../../../common/general/field/bordered_input.dart';
import '../../../../common/widgets/crystal_flushbar.dart';
import '../../../../util/colors.dart';
import '../../../../util/extensions/context_extensions.dart';

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

                        await getIt
                            .get<KeysRepository>()
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
