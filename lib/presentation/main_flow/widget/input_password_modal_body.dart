import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import '../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../domain/blocs/biometry/biometry_password_data_bloc.dart';
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
  final bloc = getIt.get<BiometryPasswordDataBloc>();
  final localAuth = LocalAuthentication();

  @override
  void dispose() {
    controller.dispose();
    bloc.close();
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
              BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
                bloc: context.watch<BiometryInfoBloc>(),
                builder: (context, biometryInfoState) => biometryInfoState.isAvailable && biometryInfoState.isEnabled
                    ? _BiometryBody(
                        bloc: bloc,
                        publicKey: widget.publicKey,
                        onSubmit: widget.onSubmit,
                        passwordBody: getPasswordBody(),
                      )
                    : getPasswordBody(),
              ),
            ],
          ),
        ),
      );

  Widget getPasswordBody() => InputPasswordField(
        onSubmit: (password) {
          bloc.add(BiometryPasswordDataEvent.setKeyPassword(
            publicKey: widget.publicKey,
            password: password,
          ));
          widget.onSubmit(password);
        },
        publicKey: widget.publicKey,
      );
}

class _BiometryBody extends StatefulWidget {
  final BiometryPasswordDataBloc bloc;
  final String publicKey;
  final Function(String password) onSubmit;
  final Widget passwordBody;

  const _BiometryBody({
    Key? key,
    required this.bloc,
    required this.publicKey,
    required this.onSubmit,
    required this.passwordBody,
  }) : super(key: key);

  @override
  __BiometryBodyState createState() => __BiometryBodyState();
}

class __BiometryBodyState extends State<_BiometryBody> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(BiometryPasswordDataEvent.getKeyPassword(widget.publicKey));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<BiometryPasswordDataBloc, BiometryPasswordDataState>(
        bloc: widget.bloc,
        listener: (context, biometryPasswordDataState) => biometryPasswordDataState.maybeWhen(
          ready: (password) => password != null ? widget.onSubmit(password) : null,
          orElse: () => null,
        ),
        builder: (context, biometryPasswordDataState) => biometryPasswordDataState.when(
          initial: () => buildBiometryBody(),
          ready: (password) => password == null ? widget.passwordBody : buildBiometryBody(),
        ),
      );

  Widget buildBiometryBody() => const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Icon(
            Icons.fingerprint,
            size: 70,
            color: CrystalColor.accent,
          ),
        ),
      );
}
