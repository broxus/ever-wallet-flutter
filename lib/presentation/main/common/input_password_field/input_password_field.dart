import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/theme.dart';
import '../../../common/widgets/custom_elevated_button.dart';
import '../../../common/widgets/custom_text_form_field.dart';
import '../../../common/widgets/text_field_clear_button.dart';
import 'input_password_field_notifier.dart';

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
  late final InputPasswordFieldNotifier notifier;

  @override
  void initState() {
    notifier = InputPasswordFieldNotifier(widget.publicKey);
    controller.addListener(() => notifier.onPasswordChange(controller.text));
    super.initState();
  }

  @override
  void dispose() {
    notifier.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            passwordField(),
            const SizedBox(
              height: 24,
            ),
            submitButton(),
          ],
        ),
      );

  Widget passwordField() => ChangeNotifierBuilder<InputPasswordFieldNotifier>(
        notifier: notifier,
        builder: (context, notifier, child) => CustomTextFormFieldWithDecoration(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          obscureText: true,
          errorText: notifier?.state.passwordState.errorText,
          hintText: 'Enter password...',
          suffixIcon: TextFieldClearButton(
            controller: controller,
          ),
        ),
      );

  Widget validationText() => ChangeNotifierBuilder<InputPasswordFieldNotifier>(
        notifier: notifier,
        builder: (context, notifier, child) => notifier?.state.formState.errorText != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    notifier!.state.formState.errorText!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CrystalColor.error,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      );

  Widget submitButton() => ChangeNotifierBuilder<InputPasswordFieldNotifier>(
        notifier: notifier,
        builder: (context, notifier, child) => CustomElevatedButton(
          onPressed:
              notifier?.state.formState.isValid ?? false ? () => onPressed(notifier!.state.passwordState.value) : null,
          text: 'Submit',
        ),
      );

  Future<void> onPressed(String value) async {
    widget.onSubmit(value);
  }
}
