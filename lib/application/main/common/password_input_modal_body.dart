import 'package:ever_wallet/application/main/common/input_password_field/password_input_form.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class PasswordInputModalBody extends StatefulWidget {
  final void Function(String password) onSubmit;
  final String? buttonText;
  final String descriptions;
  final bool autoFocus;
  final String publicKey;
  final bool isInner;

  const PasswordInputModalBody({
    required this.onSubmit,
    this.buttonText,
    this.descriptions = '',
    this.autoFocus = true,
    this.isInner = false,
    required this.publicKey,
  });

  @override
  _PasswordInputModalBodyState createState() => _PasswordInputModalBodyState();
}

class _PasswordInputModalBodyState extends State<PasswordInputModalBody> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return SafeArea(
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
                style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
                textAlign: TextAlign.start,
              ),
              const Gap(24),
            ],
            PasswordInputForm(
              onSubmit: (password) async {
                final isEnabled = context.read<BiometryRepository>().status;
                final isAvailable = context.read<BiometryRepository>().availability;

                if (isAvailable && isEnabled) {
                  await context.read<BiometryRepository>().setKeyPassword(
                        publicKey: widget.publicKey,
                        password: password,
                      );
                }

                widget.onSubmit(password);
              },
              publicKey: widget.publicKey,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
