import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../domain/blocs/biometry/biometry_set_password_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';
import 'input_password_field.dart';

class InputPasswordModalBody extends StatefulWidget {
  final Function(String password) onSubmit;
  final String? buttonText;
  final String descriptions;
  final bool autoFocus;
  final String publicKey;
  final bool isInner;

  const InputPasswordModalBody({
    required this.onSubmit,
    this.buttonText,
    this.descriptions = '',
    this.autoFocus = true,
    this.isInner = false,
    required this.publicKey,
  });

  @override
  _InputPasswordModalBodyState createState() => _InputPasswordModalBodyState();
}

class _InputPasswordModalBodyState extends State<InputPasswordModalBody> {
  final controller = TextEditingController();
  final bloc = getIt.get<BiometrySetPasswordBloc>();

  @override
  void dispose() {
    bloc.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: EdgeInsets.only(bottom: widget.isInner ? 0 : 16),
        child: Padding(
          padding: EdgeInsets.only(top: widget.isInner ? 5 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.descriptions.isNotEmpty) ...[
                Text(
                  widget.descriptions,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CrystalColor.fontDark,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.start,
                ),
                const CrystalDivider(height: 24),
              ],
              InputPasswordField(
                onSubmit: (password) async {
                  final biometryInfoBloc = context.read<BiometryInfoBloc>();

                  if (biometryInfoBloc.state.isEnabled && biometryInfoBloc.state.isEnabled) {
                    bloc.add(BiometrySetPasswordEvent.set(
                      publicKey: widget.publicKey,
                      password: password,
                    ));
                  }

                  widget.onSubmit(password);
                },
                publicKey: widget.publicKey,
              ),
            ],
          ),
        ),
      );
}
