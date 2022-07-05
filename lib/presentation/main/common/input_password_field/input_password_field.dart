import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/general/field/bordered_input.dart';
import '../../../common/widgets/custom_elevated_button.dart';
import '../../../util/colors.dart';
import '../../../util/extensions/context_extensions.dart';
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
            const SizedBox(height: 24),
            submitButton(),
          ],
        ),
      );

  Widget passwordField() => ChangeNotifierBuilder<InputPasswordFieldNotifier>(
        notifier: notifier,
        builder: (context, notifier, child) {
          final themeStyle = context.themeStyle;
          return BorderedInput(
            controller: controller,
            autofocus: true,
            obscureText: true,
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
            errorText: notifier?.state.passwordState.errorText,
            label: '${context.localization.enter_password}...',
          );
        },
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
                    style: context.themeStyle.styles.captionStyle.copyWith(
                      color: context.themeStyle.colors.errorTextColor,
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      );

  Widget submitButton() => ChangeNotifierBuilder<InputPasswordFieldNotifier>(
        notifier: notifier,
        builder: (context, notifier, child) => PrimaryElevatedButton(
          onPressed: notifier?.state.formState.isValid ?? false
              ? () => onPressed(notifier!.state.passwordState.value)
              : null,
          text: context.localization.submit,
        ),
      );

  Future<void> onPressed(String value) async {
    widget.onSubmit(value);
  }
}
