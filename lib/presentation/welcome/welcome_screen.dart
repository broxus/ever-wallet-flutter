import 'package:flutter/material.dart';

import '../../router.gr.dart';
import '../design/design.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  const SizedBox.expand(),
                  Stack(
                    children: [
                      buildBackground(),
                      buildBody(),
                    ],
                  ),
                ],
              ),
            ),
            buildActions(),
          ],
        ),
      );

  Widget buildBackground() => const Positioned.fill(
        right: 28,
        bottom: 70,
        child: AnimatedAppearance(
          delay: Duration(seconds: 1),
          duration: Duration(milliseconds: 500),
          offset: Offset(-0.5, 0.0),
          child: ColoredBox(color: CrystalColor.accentBackground),
        ),
      );

  Widget buildBody() => SafeArea(
        minimum: const EdgeInsets.only(top: 20.0) + const EdgeInsets.symmetric(horizontal: 28.0),
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(child: CrystalDivider(height: 64)),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedAppearance(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(seconds: 1),
                    child: Text(
                      LocaleKeys.welcome_screen_title.tr(),
                      style: const TextStyle(
                        fontSize: 40.0,
                        color: CrystalColor.fontHeaderDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const Flexible(
                    child: CrystalDivider(height: 16.0),
                  ),
                  AnimatedAppearance(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(seconds: 1, milliseconds: 100),
                    child: Text(
                      LocaleKeys.welcome_screen_subtitle.tr(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: CrystalColor.fontHeaderDark,
                      ),
                    ),
                  ),
                ],
              ),
              const Flexible(
                child: CrystalDivider(height: 64, minHeight: 16),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 62.0),
                child: AnimatedAppearance(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 500),
                  offset: const Offset(1.0, 0.0),
                  child: Assets.images.welcomeImage.svg(),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildActions() => SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 16.0,
        ),
        child: AnimatedAppearance(
          delay: const Duration(seconds: 1),
          offset: const Offset(0.0, 1.0),
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CrystalButton(
                text: LocaleKeys.welcome_screen_action_create.tr(),
                onTap: () => pushDecentralizationPolicyScreen(CreationActions.create),
              ),
              const SizedBox(height: 12.0),
              CrystalButton(
                type: CrystalButtonType.text,
                text: LocaleKeys.welcome_screen_action_sign_in.tr(),
                onTap: () => pushDecentralizationPolicyScreen(CreationActions.import),
              ),
            ],
          ),
        ),
      );

  void pushDecentralizationPolicyScreen(CreationActions action) => context.router.push(
        DecentralizationPolicyScreenRoute(
          action: action,
        ),
      );
}
