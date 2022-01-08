import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../design/design.dart';
import '../../../design/widgets/crystal_text_form_field.dart';
import '../../../design/widgets/custom_elevated_button.dart';

class InputPasswordField extends StatefulWidget {
  final void Function(String password) onSubmit;
  final String? buttonText;
  final bool autoFocus;
  final String publicKey;
  final String? hintText;

  const InputPasswordField({
    required this.onSubmit,
    this.buttonText,
    this.autoFocus = true,
    required this.publicKey,
    this.hintText,
  });

  @override
  _InputPasswordFieldState createState() => _InputPasswordFieldState();
}

class _InputPasswordFieldState extends State<InputPasswordField> {
  final controller = TextEditingController();
  final formValidityNotifier = ValueNotifier<bool?>(null);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CrystalTextFormField(
              controller: controller,
              autofocus: widget.autoFocus,
              obscureText: true,
              border: value ?? true
                  ? CrystalTextFormField.kInputBorder
                  : CrystalTextFormField.kInputBorder.copyWith(
                      borderSide: const BorderSide(
                        color: CrystalColor.error,
                      ),
                    ),
              hintText: widget.hintText ?? LocaleKeys.fields_password.tr(),
            ),
            const SizedBox(
              height: 24,
            ),
            CustomElevatedButton(
              onPressed: () async {
                final password = controller.text.trim();

                final isCorrect = await getIt.get<KeysRepository>().checkKeyPassword(
                      publicKey: widget.publicKey,
                      password: password,
                    );

                formValidityNotifier.value = isCorrect;

                if (isCorrect) {
                  widget.onSubmit(controller.text.trim());
                }
              },
              text: widget.buttonText ?? LocaleKeys.actions_submit.tr(),
            ),
          ],
        ),
      );
}
