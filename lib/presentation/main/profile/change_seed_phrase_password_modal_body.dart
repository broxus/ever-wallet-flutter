import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

import '../../../../../../injection.dart';
import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../generated/codegen_loader.g.dart';
import '../../../../logger.dart';
import '../../../data/extensions.dart';
import '../../common/theme.dart';
import '../../common/widgets/crystal_flushbar.dart';
import '../../common/widgets/crystal_text_form_field.dart';
import '../../common/widgets/custom_elevated_button.dart';

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
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final validationNotifier = ValueNotifier<String?>(null);
  final incorrectPasswordNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    validationNotifier.dispose();
    incorrectPasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: buildPasswordsBody(),
      );

  Widget buildPasswordsBody() => Form(
        key: formKey,
        onChanged: () {
          String? text;

          if (incorrectPasswordNotifier.value) {
            text = LocaleKeys.incorrect_password.tr();
          } else if (newPasswordController.text.isNotEmpty && !isLength(newPasswordController.text, 8)) {
            text = LocaleKeys.password_length.tr();
          }

          validationNotifier.value = text;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            buildTextField(
              controller: oldPasswordController,
              autofocus: true,
              hint: LocaleKeys.old_password.tr(),
              inputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }

                if (incorrectPasswordNotifier.value) {
                  return value;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            buildTextField(
              controller: newPasswordController,
              autofocus: false,
              hint: LocaleKeys.new_password.tr(),
              inputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }

                if (!isLength(value, 8)) {
                  return value;
                }
                return null;
              },
            ),
            buildValidationText(),
            const SizedBox(height: 24),
            CustomElevatedButton(
              onPressed: () async {
                final oldPassword = oldPasswordController.text.trim();

                final isCorrect = await getIt.get<KeysRepository>().checkKeyPassword(
                      publicKey: widget.publicKey,
                      password: oldPassword,
                    );

                if (isCorrect) {
                  incorrectPasswordNotifier.value = false;
                  final newPassword = newPasswordController.text.trim();

                  if (newPassword.isNotEmpty && (formKey.currentState?.validate() ?? false)) {
                    try {
                      context.router.pop();

                      await getIt.get<KeysRepository>().changePassword(
                            publicKey: widget.publicKey,
                            oldPassword: oldPasswordController.text.trim(),
                            newPassword: newPassword,
                          );

                      if (!mounted) return;

                      await showCrystalFlushbar(
                        context,
                        message: LocaleKeys.password_changed.tr(),
                      );
                    } catch (err, st) {
                      logger.e(err, err, st);

                      context.router.pop();

                      if (!mounted) return;

                      await showErrorCrystalFlushbar(
                        context,
                        message: (err as Exception).toUiMessage(),
                      );
                    }
                  }
                } else {
                  incorrectPasswordNotifier.value = true;
                  formKey.currentState?.validate();

                  String? text;

                  if (incorrectPasswordNotifier.value) {
                    text = LocaleKeys.incorrect_password.tr();
                  } else if (newPasswordController.text.isNotEmpty && !isLength(newPasswordController.text, 8)) {
                    text = LocaleKeys.password_length.tr();
                  }

                  validationNotifier.value = text;
                }
              },
              text: LocaleKeys.submit.tr(),
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
