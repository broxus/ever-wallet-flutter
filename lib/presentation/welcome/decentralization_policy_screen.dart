import 'package:crystal/domain/utils/decentralization_policy.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design/design.dart';
import 'widget/welcome_scaffold.dart';

class DecentralizationPolicyScreen extends StatefulWidget {
  final CreationActions action;

  const DecentralizationPolicyScreen({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  _DecentralizationPolicyScreenState createState() => _DecentralizationPolicyScreenState();
}

class _DecentralizationPolicyScreenState extends State<DecentralizationPolicyScreen> {
  final _image = ExactAssetPicture(
    SvgPicture.svgStringDecoder,
    Assets.images.signImage.path,
  );
  final _policyCheckNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _policyCheckNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        headline: LocaleKeys.welcome_policy_screen_title.tr(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  const SizedBox.expand(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildPolicyImage(),
                      const Flexible(child: CrystalDivider(height: 64.0)),
                      buildPolicyCheck(),
                      const Flexible(child: CrystalDivider(height: 64.0)),
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
          padding: const EdgeInsets.only(left: 16.0),
          child: Stack(
            children: [
              const Positioned.fill(
                top: 50,
                child: ColoredBox(color: CrystalColor.accentBackground),
              ),
              Positioned(
                left: -0.15 * constraints.maxWidth,
                right: -0.12 * constraints.maxWidth,
                child: SvgPicture(
                  _image,
                  width: 1.27 * constraints.maxWidth,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: constraints.maxWidth / 21),
                child: Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: SvgPicture(_image, width: 1.27 * constraints.maxWidth),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildPolicyCheck() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CrystalDivider(width: 16.0),
          ExpandTapWidget(
            onTap: () => _policyCheckNotifier.value = !_policyCheckNotifier.value,
            tapPadding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<bool>(
              valueListenable: _policyCheckNotifier,
              builder: (context, selected, _) => CrystalCheckbox(
                value: selected,
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
                    recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: LocaleKeys.welcome_policy_screen_description_application.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 14.0,
                height: 20.0 / 14.0,
                letterSpacing: 0.75,
                color: CrystalColor.fontDark,
              ),
            ),
          ),
          const CrystalDivider(width: 16.0),
        ],
      );

  Widget buildActions() => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: AnimatedAppearance(
          delay: const Duration(milliseconds: 450),
          offset: const Offset(0.0, 1.0),
          duration: const Duration(milliseconds: 350),
          child: ValueListenableBuilder<bool>(
            valueListenable: _policyCheckNotifier,
            builder: (context, checked, _) => CrystalButton(
              enabled: checked,
              text: LocaleKeys.actions_submit.tr(),
              onTap: () => context.router.push(NameSeedScreenRoute(action: widget.action)),
            ),
          ),
        ),
      );

  void onLinkTap() => launch(getDecentralizationPolicyLink());
}
