import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../common/widgets/animated_offstage.dart';
import '../../../../common/general/button/primary_elevated_button.dart';
import '../../../../common/widgets/custom_text_form_field.dart';
import '../../../../common/widgets/text_field_clear_button.dart';
import '../../../../common/widgets/unfocusing_gesture_detector.dart';

class CustomTokenLayout extends StatefulWidget {
  final void Function(String) onSave;

  const CustomTokenLayout({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  _CustomTokenLayoutState createState() => _CustomTokenLayoutState();
}

class _CustomTokenLayoutState extends State<CustomTokenLayout> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  final formValidityNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    controller.dispose();
    formValidityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: form(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: submitButton(),
            ),
          ],
        ),
      );

  Widget form() => Form(
        key: formKey,
        onChanged: () =>
            formValidityNotifier.value = (formKey.currentState?.validate() ?? false) && controller.text.isNotEmpty,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
          ),
          child: CustomTextFormField(
            name: AppLocalizations.of(context)!.address,
            controller: controller,
            autocorrect: false,
            enableSuggestions: false,
            hintText: AppLocalizations.of(context)!.root_token_contract,
            suffixIcon: TextFieldClearButton(controller: controller),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              if (!validateAddress(value)) {
                return AppLocalizations.of(context)!.invalid_value;
              }
              return null;
            },
            borderColor: Colors.transparent,
            errorBorderColor: Colors.transparent,
          ),
        ),
      );

  Widget submitButton() => ValueListenableBuilder<bool>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => AnimatedOffstage(
          duration: const Duration(milliseconds: 300),
          offstage: value,
          child: PrimaryElevatedButton(
            onPressed: () {
              final address = controller.text;
              context.router.pop();
              widget.onSave(address);
            },
            text: AppLocalizations.of(context)!.proceed,
          ),
        ),
      );
}
