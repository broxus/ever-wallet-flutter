import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';
import '../../widgets/input_password_field.dart';

class SubmitSendBody extends StatefulWidget {
  final String publicKey;

  const SubmitSendBody._({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  static Future<String?> open({
    required BuildContext context,
    required String publicKey,
  }) =>
      showCrystalBottomSheet<String>(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: 'Enter password',
        body: SubmitSendBody._(
          publicKey: publicKey,
        ),
      );

  @override
  _SubmitSendBodyState createState() => _SubmitSendBodyState();
}

class _SubmitSendBodyState extends State<SubmitSendBody> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputPasswordField(
                onSubmit: (password) => Navigator.of(context).pop(password),
                publicKey: widget.publicKey,
              ),
            ],
          ),
        ),
      );
}
