import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

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
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void dispose() {
    keyUpdateBloc.close();
    biometryPasswordDataBloc.close();
    checkPasswordBloc.close();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16.0),
        child: BlocListener<KeyUpdateBloc, KeyUpdateState>(
          bloc: keyUpdateBloc,
          listener: (context, state) => state.maybeWhen(
            success: () {
              context.router.navigatorKey.currentState?.pop();
              CrystalFlushbar.show(
                context,
                message: LocaleKeys.change_seed_password_modal_messages_success.tr(),
              );
            },
            orElse: () => null,
          ),
          child: BlocConsumer<KeyPasswordCheckBloc, KeyPasswordCheckState>(
              bloc: checkPasswordBloc,
              listener: (context, state) {
                state.maybeMap(
                    orElse: () => null,
                    ready: (ready) {
                      if (ready.isCorrect) {
                        final newPassword = newPasswordController.text.trim();
                        keyUpdateBloc.add(
                          KeyUpdateEvent.changePassword(
                            keySubject: widget.keySubject,
                            oldPassword: ready.password,
                            newPassword: newPassword,
                          ),
                        );
                        biometryPasswordDataBloc.add(
                          BiometryPasswordDataEvent.setKeyPassword(
                            publicKey: widget.keySubject.value.publicKey,
                            password: newPassword,
                          ),
                        );
                      }
                    });
              },
              builder: (context, state) {
                final bool isCorrect = state.map(
                  initial: (_) => true,
                  ready: (ready) => ready.isCorrect,
                );
                return getPasswordsBody(isCorrect: isCorrect);
              }),
        ),
      );

  Widget getPasswordsBody({required bool isCorrect}) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CrystalDivider(height: 24),
          CrystalTextField(
            controller: oldPasswordController,
            autofocus: true,
            obscureText: true,
            border: isCorrect
                ? CrystalTextField.kInputBorder
                : CrystalTextField.kInputBorder.copyWith(borderSide: const BorderSide(color: CrystalColor.error)),
            hintText: LocaleKeys.change_seed_password_modal_hints_old.tr(),
          ),
          const CrystalDivider(
            height: 24,
          ),
          CrystalTextField(
            controller: newPasswordController,
            autofocus: true,
            obscureText: true,
            hintText: LocaleKeys.change_seed_password_modal_hints_new.tr(),
          ),
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
      );
}
