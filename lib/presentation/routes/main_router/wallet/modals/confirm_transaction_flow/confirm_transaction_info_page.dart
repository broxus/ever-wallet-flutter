import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_confirm_transaction_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page.dart';
import '../common/send_result_page.dart';

class ConfirmTransactionInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final String transactionId;
  final String destination;
  final String amount;
  final String? comment;

  const ConfirmTransactionInfoPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    required this.transactionId,
    required this.destination,
    required this.amount,
    this.comment,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<ConfirmTransactionInfoPage> {
  final prepareConfirmTransactionBloc = getIt.get<TonWalletPrepareConfirmTransactionBloc>();
  final estimateFeesBloc = getIt.get<TonWalletEstimateFeesBloc>();

  @override
  void initState() {
    super.initState();
    prepareConfirmTransactionBloc.add(
      TonWalletPrepareConfirmTransactionEvent.prepareConfirmTransaction(
        publicKey: widget.publicKey,
        address: widget.address,
        transactionId: widget.transactionId,
      ),
    );
  }

  @override
  void dispose() {
    prepareConfirmTransactionBloc.close();
    estimateFeesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<TonWalletPrepareConfirmTransactionBloc, TonWalletPrepareConfirmTransactionState>(
        bloc: prepareConfirmTransactionBloc,
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const CustomBackButton(),
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

  Widget fee() => BlocBuilder<TonWalletPrepareConfirmTransactionBloc, TonWalletPrepareConfirmTransactionState>(
        bloc: prepareConfirmTransactionBloc,
        builder: (context, prepareConfirmTransactionState) =>
            BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
          bloc: estimateFeesBloc,
          builder: (context, estimateFeesState) {
            final subtitle = prepareConfirmTransactionState.maybeWhen(
                  error: (exception) => exception.toString(),
                  orElse: () => null,
                ) ??
                estimateFeesState.when(
                  initial: () => null,
                  success: (fees) => '${fees.toTokens().removeZeroes()} TON',
                  insufficientFunds: (fees) => 'Insufficient funds',
                  error: (exception) => exception.toString(),
                );

            final hasError = prepareConfirmTransactionState.maybeWhen(
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
        subtitle: widget.comment,
      );

  Widget submitButton() => BlocBuilder<TonWalletEstimateFeesBloc, TonWalletEstimateFeesState>(
        bloc: estimateFeesBloc,
        builder: (context, estimateFeesState) =>
            BlocBuilder<TonWalletPrepareConfirmTransactionBloc, TonWalletPrepareConfirmTransactionState>(
          bloc: prepareConfirmTransactionBloc,
          builder: (context, prepareConfirmTransactionState) {
            final message = prepareConfirmTransactionState.maybeWhen(
              success: (message) => message,
              orElse: () => null,
            );

            final sufficientFunds = estimateFeesState.maybeWhen(
              success: (_) => true,
              orElse: () => false,
            );

            return CustomElevatedButton(
              onPressed: sufficientFunds && message != null
                  ? () => onPressed(
                        message: message,
                        publicKey: widget.publicKey,
                      )
                  : null,
              text: 'Send',
            );
          },
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
    try {
      final password = await getIt.get<BiometryRepository>().getKeyPassword(
            localizedReason: 'Please authenticate to interact with wallet',
            publicKey: publicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
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
            publicKey: widget.publicKey,
            password: password,
            sendingText: 'Transaction is sending...',
            successText: 'Transaction has been sent successfully',
          ),
        ),
        (_) => false,
      );
}
