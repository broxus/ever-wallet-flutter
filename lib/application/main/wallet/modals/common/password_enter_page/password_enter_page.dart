import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/main/common/input_password_field/password_input_form_bloc.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PasswordEnterPage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;
  final void Function(String password) onSubmit;

  const PasswordEnterPage({
    super.key,
    required this.modalContext,
    required this.publicKey,
    required this.onSubmit,
  });

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<PasswordEnterPage> {
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
        child: UnfocusingGestureDetector(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              leading: const CustomBackButton(),
              title: Text(
                AppLocalizations.of(context)!.enter_password,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            body: body(),
          ),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: ModalScrollController.of(context),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    subtitle(),
                    const Gap(16),
                    passwordField(),
                    validationText(),
                    const Gap(64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    nextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget subtitle() => CrystalSubtitle(
        text: AppLocalizations.of(context)!.enter_password_to_continue,
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

  Widget nextButton() => BlocBuilder<PasswordInputFormBloc, PasswordInputFormState>(
        builder: (context, state) => PrimaryElevatedButton(
          onPressed:
              state.errorText == null ? () => onPressed(state.passwordFieldState.value!) : null,
          text: AppLocalizations.of(context)!.submit,
        ),
      );

  Future<void> onPressed(String value) async {
    widget.onSubmit(value);

    await context.read<BiometryRepository>().setKeyPassword(
          publicKey: widget.publicKey,
          password: value,
        );
  }
}
