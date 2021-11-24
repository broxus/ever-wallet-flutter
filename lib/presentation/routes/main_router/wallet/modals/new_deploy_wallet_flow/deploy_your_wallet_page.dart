import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_deploy_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/widgets/crystal_subtitle.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import 'deployment_result.dart';

class DeployYourWalletPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final List<String>? custodians;
  final int? reqConfirms;

  const DeployYourWalletPage({
    Key? key,
    required this.modalContext,
    required this.address,
    this.custodians,
    this.reqConfirms,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<DeployYourWalletPage> {
  final prepareDeployBloc = getIt.get<TonWalletPrepareDeployBloc>();
  final estimateFeesBloc = getIt.get<TonWalletEstimateFeesBloc>();

  @override
  void initState() {
    super.initState();

    if (widget.custodians != null && widget.reqConfirms != null) {
      prepareDeployBloc.add(TonWalletPrepareDeployEvent.prepareDeployWithMultipleOwners(
        address: widget.address,
        custodians: widget.custodians!,
        reqConfirms: widget.reqConfirms!,
      ));
    } else {
      prepareDeployBloc.add(TonWalletPrepareDeployEvent.prepareDeploy(widget.address));
    }
  }

  @override
  void dispose() {
    prepareDeployBloc.close();
    estimateFeesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Deploy wallet',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: body(),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: ModalScrollController.of(context),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    subtitle(),
                    const SizedBox(height: 16),
                    card(),
                    const SizedBox(height: 16),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    nextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget subtitle() => const CrystalSubtitle(
        text: 'Funds will be debited from your balance to deploy.',
      );

  Widget card() => const SectionedCard(
        sections: [
          Section(
            title: 'Account balance',
            subtitle: '124.00 TON',
          ),
          Section(
            title: 'Blockchain fee',
            subtitle: '~0.0072 TON',
          ),
        ],
      );

  Widget nextButton() => BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
        bloc: estimateFeesBloc,
        builder: (context, estimateFeesState) => BlocBuilder<TonWalletPrepareDeployBloc, TonWalletPrepareDeployState>(
            bloc: prepareDeployBloc,
            builder: (context, prepareDeployState) {
              final message = prepareDeployState.maybeWhen(
                success: (message) => message,
                orElse: () => null,
              );

              final sufficientFunds = estimateFeesState.maybeWhen(
                success: (_) => true,
                orElse: () => false,
              );

              return CustomElevatedButton(
                onPressed: sufficientFunds && message != null ? () => onPressed(message) : null,
                text: 'Deploy',
              );
            }),
      );

  void onPressed(UnsignedMessage message) => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => DeploymentResult(
                  modalContext: widget.modalContext,
                  address: widget.address,
                  message: message,
                  password: 'widget.password',
                )),
        (route) => false,
      );
}
