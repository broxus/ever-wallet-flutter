import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../../../domain/blocs/key/key_password_checking_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_subtitle.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';

class EnterPasswordPage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;
  final void Function(String password) onSubmit;

  const EnterPasswordPage({
    Key? key,
    required this.modalContext,
    required this.publicKey,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<EnterPasswordPage> {
  final controller = TextEditingController();
  final bloc = getIt.get<KeyPasswordCheckingBloc>();

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
                    submitButton(),
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

  Widget passwordField() => CustomTextFormField(
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.next,
        hintText: 'Enter password...',
        suffixIcon: SuffixIconButton(
          onPressed: () {
            controller.clear();
            Form.of(context)?.validate();
          },
          icon: Assets.images.iconCross.svg(),
        ),
      );

  Widget validationText() => BlocBuilder<KeyPasswordCheckingBloc, KeyPasswordCheckingState>(
        builder: (context, state) => state.maybeWhen(
          error: (exception) => Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  exception.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: CrystalColor.error,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ],
          ),
          orElse: () => const SizedBox(),
        ),
      );

  Widget submitButton() => CustomElevatedButton(
        onPressed: onSubmit,
        text: 'Submit',
      );

  void onSubmit() => bloc.add(KeyPasswordCheckingEvent.check(
        publicKey: widget.publicKey,
        password: controller.text,
      ));
}
