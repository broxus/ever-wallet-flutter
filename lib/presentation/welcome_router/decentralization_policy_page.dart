import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/utils/decentralization_policy.dart';
import '../design/design.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

class DecentralizationPolicyPage extends StatefulWidget {
  final CreationActions action;

  const DecentralizationPolicyPage({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  _DecentralizationPolicyPageState createState() => _DecentralizationPolicyPageState();
}

class _DecentralizationPolicyPageState extends State<DecentralizationPolicyPage> {
  final policyCheckNotifier = ValueNotifier<bool>(false);
  final tapGestureRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    tapGestureRecognizer.onTap = onLinkTap;
  }

  @override
  void dispose() {
    policyCheckNotifier.dispose();
    tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        headline: LocaleKeys.welcome_policy_screen_title.tr(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildPolicyImage(),
                      const Flexible(child: CrystalDivider(height: 64)),
                      buildPolicyCheck(),
                      const Flexible(child: CrystalDivider(height: 64)),
                    ],
                  ),
                ],
              ),
            ),
            buildActions(),
          ],
        ),
      );

  Widget buildPolicyImage() => LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Stack(
            children: [
              const Positioned.fill(
                top: 50,
                child: ColoredBox(color: CrystalColor.accentBackground),
              ),
              Positioned(
                left: -0.15 * constraints.maxWidth,
                right: -0.12 * constraints.maxWidth,
                child: Image.asset(
                  Assets.images.signImage.path,
                  width: 1.27 * constraints.maxWidth,
                  height: 0.75 * constraints.maxWidth,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: constraints.maxWidth / 21),
                child: Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Image.asset(
                    Assets.images.signImage.path,
                    width: 1.27 * constraints.maxWidth,
                    height: 0.75 * constraints.maxWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildPolicyCheck() => Row(
        children: [
          const CrystalDivider(width: 16),
          ExpandTapWidget(
            onTap: () => policyCheckNotifier.value = !policyCheckNotifier.value,
            tapPadding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<bool>(
              valueListenable: policyCheckNotifier,
              builder: (context, value, child) => CrystalCheckbox(
                value: value,
              ),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: LocaleKeys.welcome_policy_screen_description_common.tr(),
                children: [
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: LocaleKeys.welcome_policy_screen_description_link.tr(),
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: tapGestureRecognizer,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: LocaleKeys.welcome_policy_screen_description_application.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.75,
                color: CrystalColor.fontDark,
              ),
            ),
          ),
          const CrystalDivider(width: 16),
        ],
      );

  Widget buildActions() => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: ValueListenableBuilder<bool>(
          valueListenable: policyCheckNotifier,
          builder: (context, checked, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: CrystalButton(
              key: ValueKey(checked),
              enabled: checked,
              text: LocaleKeys.actions_submit.tr(),
              onTap: () => context.router.push(SeedNameRoute(action: widget.action)),
            ),
          ),
        ),
      );

  void onLinkTap() => launch(getDecentralizationPolicyLink());
}
