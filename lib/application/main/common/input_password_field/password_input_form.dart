import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/main/common/input_password_field/password_input_form_bloc.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      context.read<TransportSource>(),
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
            const SizedBox(height: 24),
            submitButton(),
          ],
        ),
      );

  Widget passwordField() => BlocBuilder<PasswordInputFormBloc, PasswordInputFormState>(
        builder: (context, state) {
          final themeStyle = context.themeStyle;
          return BorderedInput(
            controller: controller,
            autofocus: true,
            obscureText: true,
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
            errorText: state.passwordFieldState.errorText,
            label: '${context.localization.enter_password}...',
          );
        },
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
          text: context.localization.submit,
        ),
      );

  Future<void> onPressed(String value) async {
    widget.onSubmit(value);
  }
}
