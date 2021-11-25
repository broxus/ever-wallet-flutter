import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../domain/blocs/biometry/biometry_get_password_bloc.dart';
import '../../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_transfer_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page.dart';
import '../common/send_result_page.dart';

class SendInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final String destination;
  final String amount;
  final String? comment;

  const SendInfoPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    required this.destination,
    required this.amount,
    this.comment,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<SendInfoPage> {
  final prepareTransferBloc = getIt.get<TonWalletPrepareTransferBloc>();
  final estimateFeesBloc = getIt.get<TonWalletEstimateFeesBloc>();

  @override
  void initState() {
    super.initState();
    prepareTransferBloc.add(
      TonWalletPrepareTransferEvent.prepareTransfer(
        address: widget.address,
        destination: widget.destination,
        amount: widget.amount,
      ),
    );
  }

  @override
  void dispose() {
    prepareTransferBloc.close();
    estimateFeesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<TonWalletPrepareTransferBloc, TonWalletPrepareTransferState>(
        bloc: prepareTransferBloc,
        listener: (context, state) => state.maybeWhen(
          success: (message) => estimateFeesBloc.add(
            TonWalletEstimateFeesEvent.estimateFees(
              address: widget.address,
              message: message,
              amount: widget.amount,
            ),
          ),
          orElse: () => null,
        ),
        child: scaffold(),
      );

  Widget scaffold() => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Confirm transaction',
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

  Widget card() => SectionedCard(
        sections: [
          recipient(),
          amount(),
          fee(),
          if (widget.comment != null) comment(),
        ],
      );

  Widget recipient() => SectionedCardSection(
        title: 'Recipient',
        subtitle: widget.destination,
        isSelectable: true,
      );

  Widget amount() => SectionedCardSection(
        title: 'Amount',
        subtitle: '${widget.amount.toTokens().removeZeroes()} TON',
      );

  Widget fee() => BlocBuilder<TonWalletPrepareTransferBloc, TonWalletPrepareTransferState>(
        bloc: prepareTransferBloc,
        builder: (context, prepareTransferState) => BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
          bloc: estimateFeesBloc,
          builder: (context, estimateFeesState) {
            final subtitle = prepareTransferState.maybeWhen(
                  error: (exception) => exception.toString(),
                  orElse: () => null,
                ) ??
                estimateFeesState.when(
                  initial: () => null,
                  success: (fees) => '${fees.toTokens().removeZeroes()} TON',
                  insufficientFunds: (fees) => 'Insufficient funds',
                  error: (exception) => exception.toString(),
                );

            final hasError = prepareTransferState.maybeWhen(
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

  Widget comment() => SectionedCardSection(
        title: 'Comment',
        subtitle: widget.comment!,
      );

  Widget submitButton() => BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
        bloc: estimateFeesBloc,
        builder: (context, estimateFeesState) =>
            BlocBuilder<TonWalletPrepareTransferBloc, TonWalletPrepareTransferState>(
          bloc: prepareTransferBloc,
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
              onPressed: sufficientFunds && message != null ? () => onPressed(message) : null,
              text: 'Send',
            );
          },
        ),
      );

  Future<void> onPressed(UnsignedMessage message) async {
    String? password;

    final biometryInfoBloc = context.read<BiometryInfoBloc>();

    if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
      password = await getPasswordFromBiometry();
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
            publicKey: widget.publicKey,
            onSubmit: (password) => pushDeploymentResult(
              message: message,
              password: password,
            ),
          ),
        ),
      );
    }
  }

  Future<String?> getPasswordFromBiometry() async {
    final biometryGetPasswordBloc = getIt.get<BiometryGetPasswordBloc>();

    biometryGetPasswordBloc.add(
      BiometryGetPasswordEvent.get(
        localizedReason: 'Please authenticate to interact with wallet',
        publicKey: widget.publicKey,
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
            sendingText: 'Transaction is sending...',
            successText: 'Transaction has been sent successfully',
          ),
        ),
        (_) => false,
      );
}
