import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../../injection.dart';
import '../../../../../common/theme.dart';
import '../../../../../common/widgets/crystal_subtitle.dart';
import '../../../../../common/widgets/custom_back_button.dart';
import '../../../../../common/widgets/custom_elevated_button.dart';
import '../../../../../common/widgets/custom_text_form_field.dart';
import '../../../../../common/widgets/text_field_clear_button.dart';
import '../../../../../common/widgets/unfocusing_gesture_detector.dart';
import 'password_enter_page_notifier.dart';

class PasswordEnterPage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;
  final void Function(String password) onSubmit;

  const PasswordEnterPage({
    Key? key,
    required this.modalContext,
    required this.publicKey,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<PasswordEnterPage> {
  final controller = TextEditingController();
  late final PasswordEnterPageNotifier notifier;

  @override
  void initState() {
    notifier = PasswordEnterPageNotifier(widget.publicKey);
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
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const CustomBackButton(),
            title: const Text(
              'Enter password',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: body(),
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
                    const SizedBox(height: 16),
                    passwordField(),
                    validationText(),
                    const SizedBox(height: 64),
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

  Widget subtitle() => const CrystalSubtitle(
        text: 'Enter your password to continue.',
      );

  Widget passwordField() => ChangeNotifierBuilder<PasswordEnterPageNotifier>(
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

  Widget validationText() => ChangeNotifierBuilder<PasswordEnterPageNotifier>(
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

  Widget nextButton() => ChangeNotifierBuilder<PasswordEnterPageNotifier>(
        notifier: notifier,
        builder: (context, notifier, child) => CustomElevatedButton(
          onPressed:
              notifier?.state.formState.isValid ?? false ? () => onPressed(notifier!.state.passwordState.value) : null,
          text: 'Submit',
        ),
      );

  Future<void> onPressed(String value) async {
    widget.onSubmit(value);

    await getIt.get<BiometryRepository>().setKeyPassword(
          publicKey: widget.publicKey,
          password: value,
        );
  }
}
