import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

const kPasswordInputHeight = 52.0;

class AddNewSeedPasswordWidget extends StatefulWidget {
  const AddNewSeedPasswordWidget({
    required this.backAction,
    required this.nextAction,
    Key? key,
  }) : super(key: key);

  final VoidCallback backAction;
  final ValueChanged<String> nextAction;

  @override
  State<AddNewSeedPasswordWidget> createState() => _AddNewSeedPasswordWidgetState();
}

class _AddNewSeedPasswordWidgetState extends State<AddNewSeedPasswordWidget> {
  final formKey = GlobalKey<FormState>();
  final passwordFocus = FocusNode();
  final confirmFocus = FocusNode();

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextPrimaryButton.appBar(
                    onPressed: widget.backAction,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_ios, color: ColorsRes.darkBlue, size: 20),
                          Text(
                            // TODO: replace text
                            'Back',
                            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.darkBlue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                localization.enter_password,
                style: themeStyle.styles.basicStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorsRes.text,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 30),
          BorderedInput(
            height: kPasswordInputHeight,
            obscureText: true,
            controller: passwordController,
            focusNode: passwordFocus,
            label: localization.your_password,
            cursorColor: ColorsRes.text,
            validator: (_) =>
                passwordController.text.length < 8 ? localization.password_length : null,
            onSubmitted: (_) => confirmFocus.requestFocus(),
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
          BorderedInput(
            height: kPasswordInputHeight,
            obscureText: true,
            controller: confirmController,
            focusNode: confirmFocus,
            validator: (_) => confirmController.text == passwordController.text
                ? null
                : localization.passwords_match,
            label: localization.confirm_password,
            cursorColor: ColorsRes.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _nextAction(),
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
          SizedBox(
            height: bottomPadding < kPrimaryButtonHeight ? 0 : bottomPadding - kPrimaryButtonHeight,
          ),
          PrimaryElevatedButton(
            onPressed: _nextAction,
            text: localization.confirm,
          ),
        ],
      ),
    );
  }

  void _nextAction() {
    if (formKey.currentState?.validate() ?? false) {
      widget.nextAction(passwordController.text);
    }
  }
}
