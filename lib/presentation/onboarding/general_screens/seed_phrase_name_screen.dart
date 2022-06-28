import 'package:flutter/material.dart';

import '../../common/general/button/primary_button.dart';
import '../../common/general/default_appbar.dart';
import '../../common/general/field/bordered_input.dart';
import '../../util/extensions/context_extensions.dart';
import '../create_wallet/save_seed_phrase_screen.dart';
import '../sign_with_phrase/enter_seed_phrase_screen.dart';
import '../widgets/onboarding_background.dart';
import 'agree_decentralization_screen.dart';

class SeedPhraseNameRoute extends MaterialPageRoute<void> {
  SeedPhraseNameRoute(AuthType type) : super(builder: (_) => SeedPhraseNameScreen(type: type));
}

class SeedPhraseNameScreen extends StatefulWidget {
  final AuthType type;

  const SeedPhraseNameScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<SeedPhraseNameScreen> createState() => _SeedPhraseNameScreenState();
}

class _SeedPhraseNameScreenState extends State<SeedPhraseNameScreen> {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const DefaultAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(localization.enter_name, style: themeStyle.styles.appbarStyle),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: BorderedInput(
                  controller: nameController,
                  textInputAction: TextInputAction.done,
                  validator: (v) => nameController.text.isEmpty ? '' : null,
                  onSubmitted: (_) => _goNextAction(),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: localization.submit,
                onPressed: _goNextAction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goNextAction() {
    if (formKey.currentState?.validate() ?? false) {
      switch (widget.type) {
        case AuthType.createNewWallet:
          Navigator.of(context).push(SaveSeedPhraseRoute(nameController.text));
          break;
        case AuthType.signWithSeedPhrase:
          Navigator.of(context).push(EnterSeedPhraseRoute(nameController.text));
          break;
      }
    }
  }
}
