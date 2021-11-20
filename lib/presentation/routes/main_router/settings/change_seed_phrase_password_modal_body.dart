import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validators/validators.dart';

import '../../../../../../domain/blocs/key/key_password_checking_bloc.dart';
import '../../../../../../domain/blocs/key/key_update_bloc.dart';
import '../../../../../../injection.dart';
import '../../../design/design.dart';

class ChangeSeedPhrasePasswordModalBody extends StatefulWidget {
  final String publicKey;

  const ChangeSeedPhrasePasswordModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  _ChangeSeedPhrasePasswordModalBodyState createState() => _ChangeSeedPhrasePasswordModalBodyState();
}

class _ChangeSeedPhrasePasswordModalBodyState extends State<ChangeSeedPhrasePasswordModalBody> {
  final keyUpdateBloc = getIt.get<KeyUpdateBloc>();
  final checkPasswordBloc = getIt.get<KeyPasswordCheckingBloc>();
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final validationNotifier = ValueNotifier<String?>(null);
  final incorrectPasswordNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    keyUpdateBloc.close();
    checkPasswordBloc.close();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    validationNotifier.dispose();
    incorrectPasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: BlocListener<KeyUpdateBloc, KeyUpdateState>(
          bloc: keyUpdateBloc,
          listener: (context, state) {
            if (state is KeyUpdateStateSuccess) {
              context.router.navigatorKey.currentState?.pop();
              showCrystalFlushbar(
                context,
                message: LocaleKeys.change_seed_password_modal_messages_success.tr(),
              );
            }
          },
          child: BlocListener<KeyPasswordCheckingBloc, KeyPasswordCheckingState>(
            bloc: checkPasswordBloc,
            listener: (context, state) {
              if (state is KeyPasswordCheckingStateSuccess) {
                if (state.isCorrect) {
                  incorrectPasswordNotifier.value = false;
                  final newPassword = newPasswordController.text.trim();

                  if (newPassword.isNotEmpty && (formKey.currentState?.validate() ?? false)) {
                    keyUpdateBloc.add(KeyUpdateEvent.changePassword(
                      publicKey: widget.publicKey,
                      oldPassword: oldPasswordController.text.trim(),
                      newPassword: newPassword,
                    ));
                  }
                } else {
                  incorrectPasswordNotifier.value = true;
                  formKey.currentState?.validate();

                  String? text;

                  if (incorrectPasswordNotifier.value) {
                    text = 'Incorrect password';
                  } else if (newPasswordController.text.isNotEmpty && !isLength(newPasswordController.text, 8)) {
                    text = 'Password must be at least 8 symbols';
                  }

                  validationNotifier.value = text;
                }
              }
            },
            child: buildPasswordsBody(),
          ),
        ),
      );

  Widget buildPasswordsBody() => Form(
        key: formKey,
        onChanged: () {
          String? text;

          if (incorrectPasswordNotifier.value) {
            text = 'Incorrect password';
          } else if (newPasswordController.text.isNotEmpty && !isLength(newPasswordController.text, 8)) {
            text = 'Password must be at least 8 symbols';
          }

          validationNotifier.value = text;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CrystalDivider(height: 24),
            buildTextField(
              controller: oldPasswordController,
              autofocus: true,
              hint: LocaleKeys.change_seed_password_modal_hints_old.tr(),
              inputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }

                if (incorrectPasswordNotifier.value) {
                  return value;
                }
              },
            ),
            const CrystalDivider(height: 24),
            buildTextField(
              controller: newPasswordController,
              autofocus: false,
              hint: LocaleKeys.change_seed_password_modal_hints_new.tr(),
              inputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }

                if (!isLength(value, 8)) {
                  return value;
                }
              },
            ),
            buildValidationText(),
            const CrystalDivider(height: 24),
            CrystalButton(
              text: LocaleKeys.change_seed_password_modal_actions_submit.tr(),
              onTap: () {
                final oldPassword = oldPasswordController.text.trim();
                checkPasswordBloc.add(KeyPasswordCheckingEvent.check(
                  publicKey: widget.publicKey,
                  password: oldPassword,
                ));
              },
            ),
          ],
        ),
      );

  Widget buildTextField({
    required TextEditingController controller,
    required bool autofocus,
    required String hint,
    required TextInputAction inputAction,
    String? Function(String?)? validator,
  }) =>
      CrystalTextFormField(
        controller: controller,
        autofocus: autofocus,
        hintText: hint,
        keyboardType: TextInputType.text,
        obscureText: true,
        validator: validator,
        inputAction: inputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      );

  Widget buildValidationText() => ValueListenableBuilder<String?>(
        valueListenable: validationNotifier,
        builder: (context, value, child) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: value != null
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CrystalColor.error,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      );
}
