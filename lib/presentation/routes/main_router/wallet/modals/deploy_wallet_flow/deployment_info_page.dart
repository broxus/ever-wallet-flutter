import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../domain/blocs/biometry/biometry_info_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_deploy_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_deploy_with_multiple_owners_provider.dart';
import '../../../../../../injection.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/crystal_subtitle.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page.dart';
import '../common/send_result_page.dart';

class DeploymentInfoPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final List<String>? custodians;
  final int? reqConfirms;

  const DeploymentInfoPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    this.custodians,
    this.reqConfirms,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends ConsumerState<DeploymentInfoPage> {
  @override
  void initState() {
    super.initState();
    widget.custodians != null && widget.reqConfirms != null
        ? ref.read(tonWalletPrepareDeployWithMultipleOwnersProvider.notifier).prepareDeployWithMultipleOwners(
              address: widget.address,
              custodians: widget.custodians!,
              reqConfirms: widget.reqConfirms!,
            )
        : ref.read(tonWalletPrepareDeployProvider.notifier).prepareDeploy(address: widget.address);
    final future = widget.custodians != null && widget.reqConfirms != null
        ? ref.read(tonWalletPrepareDeployWithMultipleOwnersProvider.future)
        : ref.read(tonWalletPrepareDeployProvider.future);
    future.then(
      (value) => ref.read(tonWalletEstimateFeesProvider.notifier).estimateFees(
            address: widget.address,
            message: value,
          ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
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

  Widget balance() => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;

          return SectionedCardSection(
            title: 'AssetsList balance',
            subtitle: '${tonWalletInfo?.contractState.balance.toTokens().removeZeroes()} TON',
          );
        },
      );

  Widget fee() => Consumer(
        builder: (context, ref, child) {
          final message = widget.custodians != null && widget.reqConfirms != null
              ? ref.watch(tonWalletPrepareDeployWithMultipleOwnersProvider)
              : ref.watch(tonWalletPrepareDeployProvider);

          final fees = message.asData?.value != null ? ref.watch(tonWalletEstimateFeesProvider) : null;

          final subtitle = message.maybeWhen(
                error: (err, st) => err.toString(),
                orElse: () => null,
              ) ??
              fees?.when(
                data: (data) => '${data.toTokens().removeZeroes()} TON',
                error: (err, st) => err.toString(),
                loading: () => null,
              );

          final hasError = message.maybeWhen(
                error: (err, st) => true,
                orElse: () => false,
              ) ||
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

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final message = widget.custodians != null && widget.reqConfirms != null
              ? ref.watch(tonWalletPrepareDeployWithMultipleOwnersProvider).asData?.value
              : ref.watch(tonWalletPrepareDeployProvider).asData?.value;

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
              text: 'Deploy',
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
      pushDeploymentResult(
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
            onSubmit: (password) => pushDeploymentResult(
              message: message,
              publicKey: publicKey,
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
    required String publicKey,
    required String password,
  }) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SendResultPage(
            modalContext: widget.modalContext,
            address: widget.address,
            message: message,
            publicKey: publicKey,
            password: password,
            sendingText: 'Deploying...',
            successText: 'Wallet has been deployed successfully',
          ),
        ),
        (_) => false,
      );
}
