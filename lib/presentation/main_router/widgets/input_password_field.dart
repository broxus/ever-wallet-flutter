import 'package:crystal/domain/blocs/key/key_password_checking_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final bloc = getIt.get<KeyPasswordCheckingBloc>();

  @override
  void dispose() {
    controller.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<KeyPasswordCheckingBloc, KeyPasswordCheckingState>(
        bloc: bloc,
        listener: (context, state) {
          state.maybeWhen(
            ready: (isCorrect) {
              if (isCorrect) {
                widget.onSubmit(controller.text.trim());
              }
            },
            orElse: () => null,
          );
        },
        builder: (context, state) {
          final isCorrect = state.maybeWhen(
            ready: (isCorrect) => isCorrect,
            orElse: () => true,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrystalTextFormField(
                controller: controller,
                autofocus: widget.autoFocus,
                obscureText: true,
                border: isCorrect
                    ? CrystalTextFormField.kInputBorder
                    : CrystalTextFormField.kInputBorder.copyWith(
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

                  bloc.add(KeyPasswordCheckingEvent.check(
                    publicKey: widget.publicKey,
                    password: password,
                  ));
                },
              ),
            ],
          );
        },
      );
}
