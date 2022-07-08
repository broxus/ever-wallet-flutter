import 'package:ever_wallet/application/common/seed_creation/seed_name_screen.dart';
import 'package:ever_wallet/application/common/seed_creation/seed_phrase_import_screen.dart';
import 'package:ever_wallet/application/common/seed_creation/seed_phrase_save_screen.dart';
import 'package:ever_wallet/application/common/seed_creation/seed_phrase_type_screen.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/wizard/decentralization_policy_screen.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class WizardScreen extends StatelessWidget {
  const WizardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                bottom: MediaQuery.of(context).size.longestSide / 2.5,
                child: const ColoredBox(
                  color: CrystalColor.accentBackground,
                ),
              ),
              body(context),
            ],
          ),
        ),
      );

  Widget body(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    title(context),
                    const SizedBox(height: 16),
                    subtitle(context),
                    const SizedBox(height: 72),
                    image(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    createNewButton(context),
                    const SizedBox(height: 16),
                    signInButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title(BuildContext context) => CrystalTitle(
        text: AppLocalizations.of(context)!.welcome_title,
      );

  Widget subtitle(BuildContext context) => CrystalSubtitle(
        text: AppLocalizations.of(context)!.welcome_subtitle,
      );

  Widget image() => Align(
        alignment: Alignment.centerLeft,
        child: Assets.images.welcomeImage.svg(),
      );

  Widget createNewButton(BuildContext context) => CustomElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => DecentralizationPolicyScreen(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => SeedNameScreen(
                    onSubmit: (String? name) => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => SeedPhraseSaveScreen(
                          seedName: name,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        text: AppLocalizations.of(context)!.create_new_wallet,
      );

  Widget signInButton(BuildContext context) => CustomOutlinedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => DecentralizationPolicyScreen(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => SeedPhraseTypeScreen(
                    onSelected: (MnemonicType mnemonicType) => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => SeedNameScreen(
                          onSubmit: (String? name) => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => SeedPhraseImportScreen(
                                seedName: name,
                                isLegacy: mnemonicType == const MnemonicType.legacy(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        text: AppLocalizations.of(context)!.sign_in,
      );
}
