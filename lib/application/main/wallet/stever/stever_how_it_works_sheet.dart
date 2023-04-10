import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Future<void> showStEverHowItWorksSheet(BuildContext context) {
  return showEWBottomSheet(
    context,
    openFullScreen: true,
    body: (_) => const StEverHowItWorksSheet(),
  );
}

class StEverHowItWorksSheet extends StatelessWidget {
  const StEverHowItWorksSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.how_staking_works,
            style: StylesRes.header2Faktum,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _step(
                    icon: Assets.images.ever.svg(width: 48, height: 48),
                    title: localization.stake_ever_title,
                    subtitle: localization.stake_ever_subtitle,
                  ),
                  _step(
                    icon: Assets.images.stever.stever.svg(width: 48, height: 48),
                    title: localization.receive_stever_title,
                    subtitle: localization.receive_stever_subtitle,
                  ),
                  _step(
                    icon: Assets.images.stever.steverEarn.svg(width: 48, height: 48),
                    title: localization.earn_on_prices_title,
                    subtitle: localization.earn_on_prices_subtitle,
                  ),
                  _step(
                    icon: Assets.images.stever.steverDefi.svg(width: 48, height: 48),
                    title: localization.use_stever_title,
                    subtitle: localization.use_stever_subtitle,
                    needStepLine: false,
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            backgroundColor: ColorsRes.bluePrimary400,
            text: localization.got_it,
            style: StylesRes.buttonText.copyWith(color: ColorsRes.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _step({
    required SvgPicture icon,
    required String title,
    required String subtitle,
    bool needStepLine = true,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              if (needStepLine) ...[
                const SizedBox(height: 2),
                Flexible(child: Container(width: 2, color: ColorsRes.blue600)),
                const SizedBox(height: 2),
              ],
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: StylesRes.header3Faktum),
                const SizedBox(height: 4),
                Text(subtitle, style: StylesRes.regular14),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
