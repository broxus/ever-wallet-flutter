import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validators/validators.dart';

class ChangeSeedPhrasePasswordModalBody extends StatefulWidget {
  final String publicKey;

  const ChangeSeedPhrasePasswordModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  _ChangeSeedPhrasePasswordModalBodyState createState() =>
      _ChangeSeedPhrasePasswordModalBodyState();
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

  Widget buildPasswordsBody() {
    final localization = context.localization;

    return Form(
      key: formKey,
      onChanged: () {
        String? text;

        if (incorrectPasswordNotifier.value) {
          text = localization.incorrect_password;
        } else if (newPasswordController.text.isNotEmpty &&
            !isLength(newPasswordController.text, 8)) {
          text = localization.password_length;
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
            hint: localization.old_password,
            inputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              if (incorrectPasswordNotifier.value) {
                return '';
              }
              return null;
            },
          ),
          buildTextField(
            controller: newPasswordController,
            autofocus: false,
            hint: localization.new_password,
            inputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              if (!isLength(value, 8)) {
                return '';
              }
              return null;
            },
          ),
          buildValidationText(),
          const SizedBox(height: 24),
          PrimaryElevatedButton(
            onPressed: _changePassword,
            text: localization.submit,
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required bool autofocus,
    required String hint,
    required TextInputAction inputAction,
    required String? Function(String?) validator,
  }) =>
      BorderedInput(
        controller: controller,
        autofocus: autofocus,
        label: hint,
        height: 48,
        textInputType: TextInputType.text,
        obscureText: true,
        validator: validator,
        textInputAction: inputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textStyle: context.themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
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

  Future<void> _changePassword() async {
    final oldPassword = oldPasswordController.text.trim();

    final isCorrect = await context.read<KeysRepository>().checkKeyPassword(
          publicKey: widget.publicKey,
          password: oldPassword,
        );

    if (isCorrect) {
      incorrectPasswordNotifier.value = false;
      final newPassword = newPasswordController.text.trim();

      if (newPassword.isNotEmpty && (formKey.currentState?.validate() ?? false)) {
        try {
          if (!mounted) return;
          Navigator.of(context).pop();

          await context.read<KeysRepository>().changePassword(
                publicKey: widget.publicKey,
                oldPassword: oldPasswordController.text.trim(),
                newPassword: newPassword,
              );

          if (!mounted) return;

          await showFlushbar(
            context,
            message: context.localization.password_changed,
          );
        } catch (err, st) {
          logger.e(err, err, st);

          if (!mounted) return;
          Navigator.of(context).pop();

          if (!mounted) return;

          await showErrorFlushbar(
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
        text = context.localization.incorrect_password;
      } else if (newPasswordController.text.isNotEmpty &&
          !isLength(newPasswordController.text, 8)) {
        text = context.localization.password_length;
      }

      validationNotifier.value = text;
    }
  }
}
