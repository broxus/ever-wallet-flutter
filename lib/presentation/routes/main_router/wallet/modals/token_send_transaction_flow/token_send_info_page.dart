import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../domain/blocs/biometry/biometry_info_provider.dart';
import '../../../../../../domain/blocs/token_wallet/token_wallet_info_provider.dart';
import '../../../../../../domain/blocs/token_wallet/token_wallet_prepare_transfer_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_transfer_provider.dart';
import '../../../../../../injection.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page.dart';
import '../common/token_send_result_page.dart';

class TokenSendInfoPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String owner;
  final String rootTokenContract;
  final String publicKey;
  final String destination;
  final String amount;
  final bool notifyReceiver;
  final String? comment;

  const TokenSendInfoPage({
    Key? key,
    required this.modalContext,
    required this.owner,
    required this.rootTokenContract,
    required this.publicKey,
    required this.destination,
    required this.amount,
    required this.notifyReceiver,
    this.comment,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends ConsumerState<TokenSendInfoPage> {
  @override
  void initState() {
    super.initState();
    ref.read(tokenWalletPrepareTransferProvider.notifier).prepareTransfer(
          owner: widget.owner,
          rootTokenContract: widget.rootTokenContract,
          destination: widget.destination,
          amount: widget.amount,
          notifyReceiver: widget.notifyReceiver,
          payload: widget.comment,
        );
    ref.read(tokenWalletPrepareTransferProvider.future).then(
          (value) => ref.read(tonWalletPrepareTransferProvider.notifier).prepareTransfer(
                address: widget.owner,
                publicKey: widget.publicKey,
                destination: widget.destination,
                amount: widget.amount,
              ),
        );
    ref.read(tonWalletPrepareTransferProvider.future).then(
          (value) => ref.read(tonWalletEstimateFeesProvider.notifier).estimateFees(
                address: widget.owner,
                message: value,
                amount: widget.amount,
              ),
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
          notifyReceiver(),
        ],
      );

  Widget recipient() => SectionedCardSection(
        title: 'Recipient',
        subtitle: widget.destination,
        isSelectable: true,
      );

  Widget amount() => Consumer(
        builder: (context, ref, child) {
          final tokenWalletInfo = ref
              .watch(
                tokenWalletInfoProvider(
                  Tuple2(
                    widget.owner,
                    widget.rootTokenContract,
                  ),
                ),
              )
              .asData
              ?.value;

          return SectionedCardSection(
            title: 'Amount',
            subtitle: tokenWalletInfo != null
                ? '${widget.amount.toTokens(tokenWalletInfo.symbol.decimals).removeZeroes()} ${tokenWalletInfo.symbol.name}'
                : null,
          );
        },
      );

  Widget fee() => Consumer(
        builder: (context, ref, child) {
          final internalMessage = ref.watch(tokenWalletPrepareTransferProvider);

          final message = internalMessage.asData?.value != null ? ref.watch(tonWalletPrepareTransferProvider) : null;

          final fees = message?.asData?.value != null ? ref.watch(tonWalletEstimateFeesProvider) : null;

          final subtitle = internalMessage.maybeWhen(
                error: (err, st) => err.toString(),
                orElse: () => null,
              ) ??
              message?.maybeWhen(
                error: (err, st) => err.toString(),
                orElse: () => null,
              ) ??
              fees?.when(
                data: (data) => '${data.toTokens().removeZeroes()} TON',
                error: (err, st) => err.toString(),
                loading: () => null,
              );

          final hasError = internalMessage.maybeWhen(
                error: (err, st) => true,
                orElse: () => false,
              ) ||
              (message?.maybeWhen(
                    error: (err, st) => true,
                    orElse: () => false,
                  ) ??
                  false) ||
              (fees?.maybeWhen(
                    error: (err, st) => true,
                    orElse: () => false,
                  ) ??
                  false);

          return SectionedCardSection(
            title: 'Blockchain fee',
            subtitle: subtitle,
            hasError: hasError,
          );
        },
      );

  Widget comment() => SectionedCardSection(
        title: 'Comment',
        subtitle: widget.comment,
      );

  Widget notifyReceiver() => SectionedCardSection(
        title: 'Notify receiver',
        subtitle: widget.notifyReceiver ? 'Yes' : 'No',
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final internalMessage = ref.watch(tokenWalletPrepareTransferProvider).asData?.value;

          final message = internalMessage != null ? ref.watch(tonWalletPrepareTransferProvider).asData?.value : null;

          final fees = message != null ? ref.watch(tonWalletEstimateFeesProvider).asData?.value : null;

          return Consumer(
            builder: (context, ref, child) => CustomElevatedButton(
              onPressed: message != null && fees != null
                  ? () => onPressed(
                        read: ref.read,
                        message: message,
                        publicKey: widget.publicKey,
                      )
                  : null,
              text: 'Send',
            ),
          );
        },
      );

  Future<void> onPressed({
    required Reader read,
    required UnsignedMessage message,
    required String publicKey,
  }) async {
    String? password;

    final info = await read(biometryInfoProvider.future);

    if (info.isAvailable && info.isEnabled) {
      password = await getPasswordFromBiometry(publicKey);
    }

    if (!mounted) return;

    if (password != null) {
      pushTokenSendResult(
        message: message,
        publicKey: publicKey,
        password: password,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: publicKey,
            onSubmit: (password) => pushTokenSendResult(
              message: message,
              publicKey: publicKey,
              password: password,
            ),
          ),
        ),
      );
    }
  }

  Future<String?> getPasswordFromBiometry(String ownerPublicKey) async {
    try {
      final password = await getIt.get<BiometryRepository>().getKeyPassword(
            localizedReason: 'Please authenticate to interact with wallet',
            publicKey: ownerPublicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
  }

  Future<void> pushTokenSendResult({
    required UnsignedMessage message,
    required String publicKey,
    required String password,
  }) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => TokenSendResultPage(
            modalContext: widget.modalContext,
            owner: widget.owner,
            rootTokenContract: widget.rootTokenContract,
            message: message,
            publicKey: publicKey,
            password: password,
            sendingText: 'Transaction is sending...',
            successText: 'Transaction has been sent successfully',
          ),
        ),
        (_) => false,
      );
}
