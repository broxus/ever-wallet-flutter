import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/assets.gen.dart';
import '../../generated/codegen_loader.g.dart';
import '../common/theme.dart';
import '../common/utils.dart';
import '../common/widgets/crystal_title.dart';
import '../common/widgets/custom_back_button.dart';
import '../common/widgets/custom_checkbox.dart';
import '../common/widgets/custom_elevated_button.dart';

class DecentralizationPolicyPage extends StatefulWidget {
  final void Function() onPressed;

  const DecentralizationPolicyPage({
    Key? key,
    required this.onPressed,
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
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            leading: const CustomBackButton(),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Positioned.fill(
                bottom: MediaQuery.of(context).size.longestSide / 2.5,
                child: const ColoredBox(
                  color: CrystalColor.accentBackground,
                ),
              ),
              body(),
            ],
          ),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16) - const EdgeInsets.only(top: 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 96),
                    image(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    policyCheck(),
                    const SizedBox(height: 16),
                    submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => CrystalTitle(
        text: LocaleKeys.sign_policy.tr(),
      );

  Widget image() => Align(
        alignment: Alignment.centerLeft,
        child: Assets.images.signImage.svg(),
      );

  Widget policyCheck() => Row(
        children: [
          checkbox(),
          text(),
        ],
      );

  Widget checkbox() => ValueListenableBuilder<bool>(
        valueListenable: policyCheckNotifier,
        builder: (context, value, child) => CustomCheckbox(
          value: value,
          onChanged: (value) => policyCheckNotifier.value = value ?? false,
        ),
      );

  Widget text() => Expanded(
        child: Text.rich(
          TextSpan(
            text: LocaleKeys.policy_description_common.tr(),
            children: [
              const TextSpan(text: ' '),
              TextSpan(
                text: LocaleKeys.policy_description_link.tr(),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: tapGestureRecognizer,
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: LocaleKeys.policy_description_application.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );

  Widget submitButton() => ValueListenableBuilder<bool>(
        valueListenable: policyCheckNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value ? widget.onPressed : null,
          text: LocaleKeys.submit.tr(),
        ),
      );

  void onLinkTap() => launch(decentralizationPolicyLink());
}
