import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../generated/assets.gen.dart';
import '../common/theme.dart';
import '../common/widgets/crystal_subtitle.dart';
import '../common/widgets/crystal_title.dart';
import '../common/widgets/custom_elevated_button.dart';
import '../common/widgets/custom_outlined_button.dart';
import '../router.gr.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

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

  Widget createNewButton(BuildContext context) => PrimaryElevatedButton(
        onPressed: () => context.router.push(
          DecentralizationPolicyRoute(
            onPressed: () => context.router.push(
              SeedNameRoute(
                onSubmit: (String? name) => context.router.push(
                  SeedPhraseSaveRoute(
                    seedName: name,
                  ),
                ),
              ),
            ),
          ),
        ),
        text: AppLocalizations.of(context)!.create_new_wallet,
      );

  Widget signInButton(BuildContext context) => CustomOutlinedButton(
        onPressed: () => context.router.push(
          DecentralizationPolicyRoute(
            onPressed: () => context.router.push(
              SeedPhraseTypeRoute(
                onSelected: (MnemonicType mnemonicType) => context.router.push(
                  SeedNameRoute(
                    onSubmit: (String? name) => context.router.push(
                      SeedPhraseImportRoute(
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
        text: AppLocalizations.of(context)!.sign_in,
      );
}
