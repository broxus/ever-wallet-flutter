import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

typedef EnterSeedNameNavigationCallback = void Function(BuildContext context, String? name);

class EnterSeedNameWidget extends StatefulWidget {
  const EnterSeedNameWidget({
    required this.callback,
    required this.primaryColor,
    required this.defaultTextColor,
    required this.secondaryTextColor,
    required this.buttonTextColor,
    super.key,
  });

  final EnterSeedNameNavigationCallback callback;

  final Color primaryColor;
  final Color defaultTextColor;
  final Color secondaryTextColor;
  final Color buttonTextColor;

  @override
  State<EnterSeedNameWidget> createState() => _EnterSeedNameWidgetState();
}

class _EnterSeedNameWidgetState extends State<EnterSeedNameWidget> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: OnboardingAppBar(backColor: widget.primaryColor),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.seed_phrase_name_title,
                  style: StylesRes.sheetHeaderTextFaktum.copyWith(color: widget.defaultTextColor),
                ),
                const SizedBox(height: 12),
                Text(
                  localization.seed_phrase_name_description,
                  style: themeStyle.styles.basicStyle.copyWith(color: widget.secondaryTextColor),
                ),
                const SizedBox(height: 20),
                BorderedInput(
                  controller: nameController,
                  height: 52,
                  textStyle: StylesRes.basicText.copyWith(color: widget.defaultTextColor),
                  label: localization.seed_name,
                  cursorColor: widget.defaultTextColor,
                  activeBorderColor: widget.primaryColor,
                  inactiveBorderColor: widget.secondaryTextColor,
                  onSubmitted: (_) => _nextAction(),
                ),
                const Spacer(),
                PrimaryButton(
                  backgroundColor: widget.primaryColor,
                  style: StylesRes.buttonText.copyWith(color: widget.buttonTextColor),
                  text: localization.continue_word,
                  onPressed: _nextAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextAction() {
    final name = nameController.text.trim();
    widget.callback(context, name.isEmpty ? null : name);
  }
}
