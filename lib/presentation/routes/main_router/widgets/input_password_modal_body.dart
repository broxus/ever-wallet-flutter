import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../injection.dart';
import '../../../../data/repositories/biometry_repository.dart';
import '../../../../providers/biometry/biometry_availability_provider.dart';
import '../../../../providers/biometry/biometry_status_provider.dart';
import '../../../design/design.dart';
import 'input_password_field/input_password_field.dart';

class InputPasswordModalBody extends StatefulWidget {
  final void Function(String password) onSubmit;
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

  @override
  void dispose() {
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
                const SizedBox(height: 24),
              ],
              Consumer(
                builder: (context, ref, child) => InputPasswordField(
                  onSubmit: (password) async {
                    final isEnabled = await ref.read(biometryStatusProvider.future);
                    final isAvailable = await ref.read(biometryAvailabilityProvider.future);

                    if (isAvailable && isEnabled) {
                      await getIt.get<BiometryRepository>().setKeyPassword(
                            publicKey: widget.publicKey,
                            password: password,
                          );
                    }

                    widget.onSubmit(password);
                  },
                  publicKey: widget.publicKey,
                ),
              ),
            ],
          ),
        ),
      );
}
