import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';

class OnboardingSplashScreen extends StatelessWidget {
  const OnboardingSplashScreen({super.key, this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: OnboardingBackground(
          backgroundColor: ColorsRes.black,
          otherPositioned: [
            if (error != null)
              Positioned(
                bottom: 58,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: ColorsRes.onboardingErrorBackground,
                  child: Text(
                    error!,
                    style: StylesRes.basicText.copyWith(color: ColorsRes.white),
                  ),
                ),
              ),
          ],
          child: Center(
            child: Assets.images.everSymbol.svg(width: 86, height: 86, color: ColorsRes.lightBlue),
          ),
        ),
      ),
    );
  }
}
