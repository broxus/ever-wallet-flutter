import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../design/widgets/custom_close_button.dart';
import '../../../design/widgets/custom_elevated_button.dart';
import '../../../design/widgets/custom_outlined_button.dart';
import '../../../design/widgets/modal_title.dart';
import '../../router.gr.dart';

class DeployYourWalletPage extends StatefulWidget {
  const DeployYourWalletPage({Key? key}) : super(key: key);

  @override
  _DeployYourWalletPageState createState() => _DeployYourWalletPageState();
}

class _DeployYourWalletPageState extends State<DeployYourWalletPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: title(),
                  ),
                  closeButton(),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Flexible(
                    child: backButton(),
                  ),
                  Flexible(
                    flex: 2,
                    child: nextButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget title() => const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: ModalTitle('Deploy your wallet'),
      );

  Widget closeButton() => CustomCloseButton(
        onPressed: () => context.router.navigate(const WalletRoute()),
      );

  Widget backButton() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: CustomOutlinedButton(
          onPressed: context.router.pop,
          text: 'Back',
        ),
      );

  Widget nextButton() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: CustomElevatedButton(
          onPressed: () => context.router.push(const DeployYourWalletRoute()),
          text: 'Next',
        ),
      );
}
