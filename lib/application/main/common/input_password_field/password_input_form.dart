import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/main/common/input_password_field/password_input_form_bloc.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class PasswordInputForm extends StatefulWidget {
  final void Function(String password) onSubmit;
  final String? buttonText;
  final bool autoFocus;
  final String publicKey;
  final String? hintText;

  const PasswordInputForm({
    required this.onSubmit,
    this.buttonText,
    this.autoFocus = true,
    required this.publicKey,
    this.hintText,
  });

  @override
  _PasswordInputFormState createState() => _PasswordInputFormState();
}

class _PasswordInputFormState extends State<PasswordInputForm> {
  final controller = TextEditingController();
  late final PasswordInputFormBloc passwordInputFormBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    passwordInputFormBloc = PasswordInputFormBloc(
      context.read<KeysRepository>(),
      widget.publicKey,
    );
    controller.addListener(
      () => passwordInputFormBloc.add(PasswordInputFormEvent.onPasswordChange(controller.text)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    passwordInputFormBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<PasswordInputFormBloc>.value(
        value: passwordInputFormBloc,
        child: Column(
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

  Widget passwordField() => BlocBuilder<PasswordInputFormBloc, PasswordInputFormState>(
        builder: (context, state) => CustomTextFormFieldWithDecoration(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          obscureText: true,
          errorText: state.passwordFieldState.errorText,
          hintText: '${AppLocalizations.of(context)!.enter_password}...',
          suffixIcon: TextFieldClearButton(
            controller: controller,
          ),
        ),
      );

  Widget validationText() => BlocBuilder<PasswordInputFormBloc, PasswordInputFormState>(
        builder: (context, state) => state.errorText != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(16),
                  Text(
                    state.errorText!,
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

  Widget submitButton() => BlocBuilder<PasswordInputFormBloc, PasswordInputFormState>(
        builder: (context, state) => CustomElevatedButton(
          onPressed:
              state.errorText == null ? () => onPressed(state.passwordFieldState.value!) : null,
          text: AppLocalizations.of(context)!.submit,
        ),
      );

  Future<void> onPressed(String value) async {
    widget.onSubmit(value);
  }
}
