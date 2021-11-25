import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../../../domain/blocs/key/key_password_checking_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_subtitle.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';

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
  final bloc = getIt.get<KeyPasswordCheckingBloc>();
  final passwordFieldKey = GlobalKey<FormBuilderFieldState>();

  @override
  void dispose() {
    controller.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<KeyPasswordCheckingBloc, KeyPasswordCheckingState>(
        bloc: bloc,
        listener: (context, state) => state.maybeWhen(
          success: (isCorrect) => isCorrect ? widget.onSubmit(controller.text) : null,
          orElse: () => null,
        ),
        child: UnfocusingGestureDetector(
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Enter password',
                style: TextStyle(
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
                    const SizedBox(height: 16),
                    passwordField(),
                    validationText(),
                    const SizedBox(height: 16),
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

  Widget passwordField() => BlocListener<KeyPasswordCheckingBloc, KeyPasswordCheckingState>(
        bloc: bloc,
        listener: (context, state) => state.maybeWhen(
          success: (isCorrect) {
            if (!isCorrect) {
              passwordFieldKey.currentState?.invalidate('Invalid password');
            } else {
              passwordFieldKey.currentState?.validate();
            }
          },
          error: (exception) {
            passwordFieldKey.currentState?.invalidate(exception.toString());
          },
          orElse: () {
            passwordFieldKey.currentState?.validate();
          },
        ),
        child: CustomTextFormField(
          fieldKey: passwordFieldKey,
          name: 'password',
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          obscureText: true,
          textInputAction: TextInputAction.next,
          hintText: 'Enter password...',
          suffixIcon: TextFieldClearButton(
            controller: controller,
          ),
        ),
      );

  Widget validationText() => BlocBuilder<KeyPasswordCheckingBloc, KeyPasswordCheckingState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          success: (isCorrect) => !isCorrect
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 16),
                    Text(
                      'Invalid password',
                      style: TextStyle(
                        fontSize: 14,
                        color: CrystalColor.error,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          orElse: () => const SizedBox(),
        ),
      );

  Widget nextButton() => CustomElevatedButton(
        onPressed: onPressed,
        text: 'Submit',
      );

  void onPressed() => bloc.add(
        KeyPasswordCheckingEvent.check(
          publicKey: widget.publicKey,
          password: controller.text,
        ),
      );
}
