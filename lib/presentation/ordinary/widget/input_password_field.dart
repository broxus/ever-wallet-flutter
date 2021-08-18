import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/blocs/key/key_password_check_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';

class InputPasswordField extends StatefulWidget {
  final Function(String password) onSubmit;
  final String? buttonText;
  final bool autoFocus;
  final String publicKey;
  final String? hintText;

  const InputPasswordField({
    required this.onSubmit,
    this.buttonText,
    this.autoFocus = true,
    required this.publicKey,
    this.hintText,
  });

  @override
  _InputPasswordFieldState createState() => _InputPasswordFieldState();
}

class _InputPasswordFieldState extends State<InputPasswordField> {
  final controller = TextEditingController();
  final checkPasswordBloc = getIt.get<KeyPasswordCheckBloc>();

  @override
  void dispose() {
    controller.dispose();
    checkPasswordBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<KeyPasswordCheckBloc, KeyPasswordCheckState>(
        bloc: checkPasswordBloc,
        listener: (context, state) {
          state.maybeMap(
              orElse: () => null,
              ready: (ready) {
                if (ready.isCorrect) {
                  widget.onSubmit(ready.password);
                }
              });
        },
        builder: (context, state) {
          final isCorrect = state.map(
            initial: (_) => true,
            ready: (ready) => ready.isCorrect,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrystalTextField(
                controller: controller,
                autofocus: widget.autoFocus,
                obscureText: true,
                border: isCorrect
                    ? CrystalTextField.kInputBorder
                    : CrystalTextField.kInputBorder.copyWith(
                        borderSide: const BorderSide(
                          color: CrystalColor.error,
                        ),
                      ),
                hintText: widget.hintText ?? LocaleKeys.fields_password.tr(),
              ),
              const CrystalDivider(
                height: 24,
              ),
              CrystalButton(
                text: widget.buttonText ?? LocaleKeys.actions_submit.tr(),
                onTap: () {
                  final password = controller.text.trim();
                  checkPasswordBloc.add(KeyPasswordCheckEvent.checkPassword(
                    publicKey: widget.publicKey,
                    password: password,
                  ));
                },
              )
            ],
          );
        },
      );
}
