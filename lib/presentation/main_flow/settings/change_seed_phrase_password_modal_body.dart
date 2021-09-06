import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:validators/validators.dart';

import '../../../domain/blocs/biometry/biometry_password_data_bloc.dart';
import '../../../domain/blocs/key/key_password_check_bloc.dart';
import '../../../domain/blocs/key/key_update_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';

class ChangeSeedPhrasePasswordModalBody extends StatefulWidget {
  final KeySubject keySubject;

  const ChangeSeedPhrasePasswordModalBody({
    Key? key,
    required this.keySubject,
  }) : super(key: key);

  @override
  _ChangeSeedPhrasePasswordModalBodyState createState() => _ChangeSeedPhrasePasswordModalBodyState();
}

class _ChangeSeedPhrasePasswordModalBodyState extends State<ChangeSeedPhrasePasswordModalBody> {
  final keyUpdateBloc = getIt.get<KeyUpdateBloc>();
  final biometryPasswordDataBloc = getIt.get<BiometryPasswordDataBloc>();
  final checkPasswordBloc = getIt.get<KeyPasswordCheckBloc>();
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final validationNotifier = ValueNotifier<String?>('');
  final incorrectPasswordNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    keyUpdateBloc.close();
    biometryPasswordDataBloc.close();
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
          listener: (context, state) => state.maybeWhen(
            success: () {
              context.router.navigatorKey.currentState?.pop();
              showCrystalFlushbar(
                context,
                message: LocaleKeys.change_seed_password_modal_messages_success.tr(),
              );
            },
            orElse: () => null,
          ),
          child: BlocListener<KeyPasswordCheckBloc, KeyPasswordCheckState>(
            bloc: checkPasswordBloc,
            listener: (context, state) {
              state.maybeMap(
                orElse: () => null,
                ready: (ready) {
                  if (ready.isCorrect) {
                    incorrectPasswordNotifier.value = false;
                    final newPassword = newPasswordController.text.trim();

                    if (formKey.currentState?.validate() ?? false) {
                      keyUpdateBloc.add(KeyUpdateEvent.changePassword(
                        keySubject: widget.keySubject,
                        oldPassword: ready.password,
                        newPassword: newPassword,
                      ));
                    }
                  } else {
                    incorrectPasswordNotifier.value = true;
                    formKey.currentState?.validate();
                  }
                },
              );
            },
            child: buildPasswordsBody(),
          ),
        ),
      );

  Widget buildPasswordsBody() => Form(
        key: formKey,
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
                if (value == null) {
                  return null;
                }

                String? text;

                if (incorrectPasswordNotifier.value) {
                  text = "Incorrect password";
                }

                validationNotifier.value = text;

                return text;
              },
            ),
            const CrystalDivider(height: 24),
            buildTextField(
              controller: newPasswordController,
              autofocus: false,
              hint: LocaleKeys.change_seed_password_modal_hints_new.tr(),
              inputAction: TextInputAction.done,
              validator: (value) {
                if (value == null) {
                  return null;
                }

                String? text;

                if (!isLength(value, 8)) {
                  text = "Password must be at least 8 symbols";
                }

                if (!incorrectPasswordNotifier.value) {
                  validationNotifier.value = text;
                }

                return text;
              },
            ),
            buildValidationText(),
            const CrystalDivider(height: 24),
            CrystalButton(
              text: LocaleKeys.change_seed_password_modal_actions_submit.tr(),
              onTap: () {
                final oldPassword = oldPasswordController.text.trim();
                checkPasswordBloc.add(KeyPasswordCheckEvent.checkPassword(
                  publicKey: widget.keySubject.value.publicKey,
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
    required String? Function(String?)? validator,
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
