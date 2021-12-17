import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../design/design.dart';

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
            const CrystalDivider(height: 20),
            CrystalTextFormField(
              controller: controller,
              autofocus: true,
              formatters: [LengthLimitingTextInputFormatter(50)],
              hintText: LocaleKeys.new_seed_name_hint.tr(),
            ),
            const CrystalDivider(height: 24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => CrystalButton(
                text: LocaleKeys.rename_key_modal_actions_rename.tr(),
                onTap: value.text.isEmpty
                    ? null
                    : () async {
                        try {
                          await getIt.get<KeysRepository>().renameKey(
                                publicKey: widget.publicKey,
                                name: value.text,
                              );

                          if (!mounted) return;

                          await showCrystalFlushbar(
                            context,
                            message: LocaleKeys.rename_key_modal_message_success.tr(),
                          );

                          context.router.navigatorKey.currentState?.pop();
                        } catch (err) {
                          if (!mounted) return;

                          await showErrorCrystalFlushbar(
                            context,
                            message: err.toString(),
                          );
                        }
                      },
              ),
            )
          ],
        ),
      );
}
