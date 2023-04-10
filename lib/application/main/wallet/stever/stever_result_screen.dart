import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';

/// Result screen of staking/unstaking ever
class StEverResultScreen extends StatelessWidget {
  const StEverResultScreen({
    required this.title,
    required this.subtitle,
    required this.modalContext,
    this.isCompleted = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final BuildContext modalContext;

  /// If completed, then display check icon, else timer
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(modalContext).pop(true);
        return Future.value(false);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted)
                        Assets.images.check.svg(height: 50, width: 69)
                      else
                        Assets.images.history.svg(height: 66, width: 66),
                      const SizedBox(height: 25),
                      Text(
                        title,
                        style: StylesRes.header2Faktum.copyWith(color: ColorsRes.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: StylesRes.regular16.copyWith(color: ColorsRes.neutral400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.only(bottom: 16),
                child: PrimaryButton(
                  text: context.localization.continue_word,
                  onPressed: () => Navigator.of(modalContext).pop(true),
                  backgroundColor: ColorsRes.bluePrimary400,
                  style: StylesRes.buttonText.copyWith(color: ColorsRes.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
