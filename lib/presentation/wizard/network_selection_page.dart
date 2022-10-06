import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../../data/constants.dart';
import '../../data/repositories/transport_repository.dart';
import '../../injection.dart';
import '../common/widgets/crystal_subtitle.dart';
import '../common/widgets/crystal_title.dart';
import '../common/widgets/custom_elevated_button.dart';
import '../router.gr.dart';

class NetworkSelectionPage extends StatelessWidget {
  const NetworkSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: body(context),
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
                    logo(context),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    everButton(context),
                    const SizedBox(height: 16),
                    venomButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title(BuildContext context) => const CrystalTitle(
        text: 'Select prefered network',
      );

  Widget subtitle(BuildContext context) => const CrystalSubtitle(
        text: 'Choose between Everscale and Venom networks',
      );

  Widget logo(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: OverflowBox(
          maxWidth: MediaQuery.of(context).size.width * 1.25,
          child: ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSvg(rootBundle, 'assets/images/networks.svg'),
          ),
        ),
      );

  Widget everButton(BuildContext context) => CustomElevatedButton(
        onPressed: () async {
          await getIt.get<TransportRepository>().updateTransport(
                kNetworkPresets.firstWhere((e) => e.name == 'Mainnet (ADNL)'),
              );

          context.router.push(const WelcomeRoute());
        },
        text: 'Everscale',
      );

  Widget venomButton(BuildContext context) => CustomElevatedButton(
        onPressed: () async {
          await getIt.get<TransportRepository>().updateTransport(
                kNetworkPresets.firstWhere((e) => e.name == 'Mainnet Venom (ADNL)'),
              );

          context.router.push(const WelcomeRoute());
        },
        text: 'Venom',
      );
}
