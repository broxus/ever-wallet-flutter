import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/design.dart';
import '../../../../../design/widgets/animated_offstage.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';

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
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  form(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  submitButton(),
                ],
              ),
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
            name: 'address',
            controller: controller,
            autocorrect: false,
            enableSuggestions: false,
            hintText: LocaleKeys.add_assets_modal_create_layout_contract_hint.tr(),
            suffixIcon: TextFieldClearButton(controller: controller),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              if (!validateAddress(value)) {
                return 'Invalid value';
              }
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
          child: CustomElevatedButton(
            onPressed: () {
              final address = controller.text;
              context.router.pop();
              widget.onSave(address);
            },
            text: LocaleKeys.actions_proceed.tr(),
          ),
        ),
      );
}
