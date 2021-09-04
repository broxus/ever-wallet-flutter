import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/design.dart';
import '../router.gr.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    buildBackground(),
                    buildBody(),
                  ],
                ),
              ),
              buildActions(),
            ],
          ),
        ),
      );

  Widget buildBackground() => const Positioned.fill(
        right: 28,
        bottom: 70,
        child: ColoredBox(color: CrystalColor.accentBackground),
      );

  Widget buildBody() => SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 20, 28, 0),
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: CrystalDivider(height: 64),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocaleKeys.welcome_screen_title.tr(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: CrystalColor.fontHeaderDark,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const Flexible(
                    child: CrystalDivider(height: 16),
                  ),
                  Text(
                    LocaleKeys.welcome_screen_subtitle.tr(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CrystalColor.fontHeaderDark,
                    ),
                  ),
                ],
              ),
              const Flexible(
                child: CrystalDivider(height: 64, minHeight: 16),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 62),
                child: Image.asset(Assets.images.welcomeImage.path),
              ),
            ],
          ),
        ),
      );

  Widget buildActions() => SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CrystalButton(
              text: LocaleKeys.welcome_screen_action_create.tr(),
              onTap: () => pushDecentralizationPolicyScreen(CreationActions.create),
            ),
            const SizedBox(height: 12),
            CrystalButton(
              type: CrystalButtonType.text,
              text: LocaleKeys.welcome_screen_action_sign_in.tr(),
              onTap: () => pushDecentralizationPolicyScreen(CreationActions.import),
            ),
          ],
        ),
      );

  void pushDecentralizationPolicyScreen(CreationActions action) => context.router.push(
        DecentralizationPolicyRoute(action: action),
      );
}
