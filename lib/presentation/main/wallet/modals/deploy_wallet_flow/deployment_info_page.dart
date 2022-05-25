import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../../providers/biometry/biometry_availability_provider.dart';
import '../../../../../../providers/biometry/biometry_status_provider.dart';
import '../../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../../../providers/ton_wallet/ton_wallet_prepare_deploy_provider.dart';
import '../../../../../data/extensions.dart';
import '../../../../../generated/codegen_loader.g.dart';
import '../../../../common/constants.dart';
import '../../../../common/extensions.dart';
import '../../../../common/widgets/crystal_subtitle.dart';
import '../../../../common/widgets/custom_back_button.dart';
import '../../../../common/widgets/custom_elevated_button.dart';
import '../../../../common/widgets/sectioned_card.dart';
import '../../../../common/widgets/sectioned_card_section.dart';
import '../common/password_enter_page/password_enter_page.dart';
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
    ref.read(tonWalletPrepareDeployProvider.notifier).prepareDeploy(
          address: widget.address,
          custodians: widget.custodians,
          reqConfirms: widget.reqConfirms,
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const CustomBackButton(),
          title: Text(
            LocaleKeys.deploy_wallet.tr(),
            style: const TextStyle(
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

  Widget subtitle() => CrystalSubtitle(
        text: LocaleKeys.funds_to_deploy.tr(),
      );

  Widget card() => SectionedCard(
        sections: [
          balance(),
          fee(),
          if (widget.custodians != null) ...custodians(),
          if (widget.reqConfirms != null) reqConfirms(),
        ],
      );

  Widget balance() => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;

          return SectionedCardSection(
            title: LocaleKeys.account_balance.tr(),
            subtitle: '${tonWalletInfo?.contractState.balance.toTokens().removeZeroes()} $kEverTicker',
          );
        },
      );

  Widget fee() => Consumer(
        builder: (context, ref, child) {
          final result = ref.watch(tonWalletPrepareDeployProvider);

          final subtitle = result.when(
            data: (data) => '${data.item2.toTokens().removeZeroes()} $kEverTicker',
            error: (err, st) => (err as Exception).toUiMessage(),
            loading: () => null,
          );

          final hasError = result.maybeWhen(
            error: (error, stackTrace) => true,
            orElse: () => false,
          );

          return SectionedCardSection(
            title: LocaleKeys.blockchain_fee.tr(),
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
          title: LocaleKeys.custodian_n.tr(args: ['${e.key + 1}']),
          subtitle: e.value,
          isSelectable: true,
        ),
      )
      .toList();

  Widget reqConfirms() => SectionedCardSection(
        title: LocaleKeys.required_confirms.tr(),
        subtitle: LocaleKeys.n_of_k.tr(args: [(widget.reqConfirms!.toString()), '${widget.custodians!.length}']),
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final result = ref.watch(tonWalletPrepareDeployProvider).asData?.value;

          return CustomElevatedButton(
            onPressed: result?.item1 != null && result?.item2 != null
                ? () => onPressed(
                      read: ref.read,
                      message: result!.item1,
                      publicKey: widget.publicKey,
                    )
                : null,
            text: LocaleKeys.deploy.tr(),
          );
        },
      );

  Future<void> onPressed({
    required Reader read,
    required UnsignedMessage message,
    required String publicKey,
  }) async {
    String? password;

    final isEnabled = await read(biometryStatusProvider.future);
    final isAvailable = await read(biometryAvailabilityProvider.future);

    if (isAvailable && isEnabled) {
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
        MaterialPageRoute<void>(
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
            localizedReason: LocaleKeys.authentication_reason.tr(),
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
            sendingText: '${LocaleKeys.deploying.tr()}...',
            successText: LocaleKeys.wallet_deployed.tr(),
          ),
        ),
        (_) => false,
      );
}