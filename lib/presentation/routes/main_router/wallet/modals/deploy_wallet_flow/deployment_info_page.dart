import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../domain/blocs/biometry/biometry_get_password_bloc.dart';
import '../../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_deploy_bloc.dart';
import '../../../../../../domain/models/ton_wallet_info.dart';
import '../../../../../../injection.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/crystal_subtitle.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page.dart';
import '../common/send_result_page.dart';

class DeploymentInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final List<String>? custodians;
  final int? reqConfirms;

  const DeploymentInfoPage({
    Key? key,
    required this.modalContext,
    required this.address,
    this.custodians,
    this.reqConfirms,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<DeploymentInfoPage> {
  final prepareDeployBloc = getIt.get<TonWalletPrepareDeployBloc>();
  final estimateFeesBloc = getIt.get<TonWalletEstimateFeesBloc>();
  final infoBloc = getIt.get<TonWalletInfoBloc>();

  @override
  void initState() {
    super.initState();
    infoBloc.add(TonWalletInfoEvent.load(widget.address));
    if (widget.custodians != null && widget.reqConfirms != null) {
      prepareDeployBloc.add(
        TonWalletPrepareDeployEvent.prepareDeployWithMultipleOwners(
          address: widget.address,
          custodians: widget.custodians!,
          reqConfirms: widget.reqConfirms!,
        ),
      );
    } else {
      prepareDeployBloc.add(TonWalletPrepareDeployEvent.prepareDeploy(widget.address));
    }
  }

  @override
  void dispose() {
    prepareDeployBloc.close();
    estimateFeesBloc.close();
    infoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<TonWalletPrepareDeployBloc, TonWalletPrepareDeployState>(
        bloc: prepareDeployBloc,
        listener: (context, state) => state.maybeWhen(
          success: (message) => estimateFeesBloc.add(
            TonWalletEstimateFeesEvent.estimateFees(
              address: widget.address,
              message: message,
            ),
          ),
          orElse: () => null,
        ),
        child: scaffold(),
      );

  Widget scaffold() => Scaffold(
        appBar: AppBar(
          leading: const CustomBackButton(),
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
                    submitButton(),
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

  Widget card() => SectionedCard(
        sections: [
          balance(),
          fee(),
          if (widget.custodians != null) ...custodians(),
          if (widget.custodians != null && widget.reqConfirms != null) reqConfirms(),
        ],
      );

  Widget balance() => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: infoBloc,
        builder: (context, state) => SectionedCardSection(
          title: 'Account balance',
          subtitle: '${state?.contractState.balance.toTokens().removeZeroes()} TON',
        ),
      );

  Widget fee() => BlocBuilder<TonWalletPrepareDeployBloc, TonWalletPrepareDeployState>(
        bloc: prepareDeployBloc,
        builder: (context, prepareDeployState) => BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
          bloc: estimateFeesBloc,
          builder: (context, estimateFeesState) {
            final subtitle = prepareDeployState.maybeWhen(
                  error: (exception) => exception.toString(),
                  orElse: () => null,
                ) ??
                estimateFeesState.when(
                  initial: () => null,
                  success: (fees) => '${fees.toTokens().removeZeroes()} TON',
                  insufficientFunds: (fees) => 'Insufficient funds',
                  error: (exception) => exception.toString(),
                );

            final hasError = prepareDeployState.maybeWhen(
                  error: (_) => true,
                  orElse: () => false,
                ) ||
                estimateFeesState.maybeWhen(
                  insufficientFunds: (_) => true,
                  error: (_) => true,
                  orElse: () => false,
                );

            return SectionedCardSection(
              title: 'Blockchain fee',
              subtitle: subtitle,
              hasError: hasError,
            );
          },
        ),
      );

  List<Widget> custodians() => widget.custodians!
      .asMap()
      .entries
      .map(
        (e) => SectionedCardSection(
          title: 'Custodian ${e.key + 1}',
          subtitle: e.value,
          isSelectable: true,
        ),
      )
      .toList();

  Widget reqConfirms() => SectionedCardSection(
        title: 'Required confirms',
        subtitle: '${widget.reqConfirms!.toString()} of ${widget.custodians!.length}',
      );

  Widget submitButton() => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: infoBloc,
        builder: (context, infoState) => BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
          bloc: estimateFeesBloc,
          builder: (context, estimateFeesState) => BlocBuilder<TonWalletPrepareDeployBloc, TonWalletPrepareDeployState>(
            bloc: prepareDeployBloc,
            builder: (context, prepareTransferState) {
              final message = prepareTransferState.maybeWhen(
                success: (message) => message,
                orElse: () => null,
              );

              final sufficientFunds = estimateFeesState.maybeWhen(
                success: (_) => true,
                orElse: () => false,
              );

              return CustomElevatedButton(
                onPressed: sufficientFunds && message != null && infoState != null
                    ? () => onPressed(
                          message: message,
                          publicKey: infoState.publicKey,
                        )
                    : null,
                text: 'Deploy',
              );
            },
          ),
        ),
      );

  Future<void> onPressed({
    required UnsignedMessage message,
    required String publicKey,
  }) async {
    String? password;

    final biometryInfoBloc = context.read<BiometryInfoBloc>();

    if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
      password = await getPasswordFromBiometry(publicKey);
    }

    if (!mounted) return;

    if (password != null) {
      pushDeploymentResult(
        message: message,
        password: password,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: publicKey,
            onSubmit: (password) => pushDeploymentResult(
              message: message,
              password: password,
            ),
          ),
        ),
      );
    }
  }

  Future<String?> getPasswordFromBiometry(String publicKey) async {
    final biometryGetPasswordBloc = getIt.get<BiometryGetPasswordBloc>();

    biometryGetPasswordBloc.add(
      BiometryGetPasswordEvent.get(
        localizedReason: 'Please authenticate to interact with wallet',
        publicKey: publicKey,
      ),
    );

    final state = await biometryGetPasswordBloc.stream.firstWhere(
      (e) => e.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () async {
      biometryGetPasswordBloc.close();
    });

    return state.maybeWhen(
      success: (password) => password,
      orElse: () => null,
    );
  }

  Future<void> pushDeploymentResult({
    required UnsignedMessage message,
    required String password,
  }) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SendResultPage(
            modalContext: widget.modalContext,
            address: widget.address,
            message: message,
            password: password,
            sendingText: 'Deploying...',
            successText: 'Wallet has been deployed successfully',
          ),
        ),
        (_) => false,
      );
}
