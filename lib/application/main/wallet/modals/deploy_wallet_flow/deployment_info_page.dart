import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_prepare_deploy_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:ever_wallet/application/common/widgets/transport_builder.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/send_result_page.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class DeploymentInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final List<String>? custodians;
  final int? reqConfirms;

  const DeploymentInfoPage({
    super.key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    this.custodians,
    this.reqConfirms,
  });

  @override
  _NewSelectWalletTypePageState createState() =>
      _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<DeploymentInfoPage> {
  @override
  Widget build(BuildContext context) =>
      BlocProvider<TonWalletPrepareDeployBloc>(
        key: ValueKey(widget.address),
        create: (context) => TonWalletPrepareDeployBloc(
          context.read<TonWalletsRepository>(),
          widget.address,
        )..add(
            TonWalletPrepareDeployEvent.prepareDeploy(
              custodians: widget.custodians,
              reqConfirms: widget.reqConfirms,
            ),
          ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const CustomBackButton(),
            title: Text(
              AppLocalizations.of(context)!.deploy_wallet,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: body(),
        ),
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
                    const Gap(16),
                    card(),
                    const Gap(64),
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
        text: AppLocalizations.of(context)!.funds_to_deploy,
      );

  Widget card() => SectionedCard(
        sections: [
          balance(),
          fee(),
          if (widget.custodians != null) ...custodians(),
          if (widget.reqConfirms != null) reqConfirms(),
        ],
      );

  Widget balance() => TransportBuilderWidget(
        builder: (context, data) {
          return AsyncValueStreamProvider<String>(
            create: (context) => context
                .read<TonWalletsRepository>()
                .contractStateStream(widget.address)
                .map((e) => e.balance),
            builder: (context, child) {
              final balance = context.watch<AsyncValue<String>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

              final ticker = data.config.symbol;

              return SectionedCardSection(
                title: AppLocalizations.of(context)!.account_balance,
                subtitle: '${balance?.toTokens().removeZeroes()} $ticker',
              );
            },
          );
        },
      );

  Widget fee() => TransportBuilderWidget(
        builder: (context, data) {
          return BlocBuilder<TonWalletPrepareDeployBloc,
              TonWalletPrepareDeployState>(
            builder: (context, state) {
              final subtitle = state.maybeWhen(
                ready: (unsignedMessage, fees) =>
                    '${fees.toTokens().removeZeroes()} ${data.config.symbol}',
                error: (error) => error,
                orElse: () => null,
              );

              final hasError = state.maybeWhen(
                error: (error) => true,
                orElse: () => false,
              );

              return SectionedCardSection(
                title: AppLocalizations.of(context)!.blockchain_fee,
                subtitle: subtitle,
                hasError: hasError,
              );
            },
          );
        },
      );

  List<Widget> custodians() => widget.custodians!
      .asMap()
      .entries
      .map(
        (e) => SectionedCardSection(
          title: AppLocalizations.of(context)!.custodian_n('${e.key + 1}'),
          subtitle: e.value,
          isSelectable: true,
        ),
      )
      .toList();

  Widget reqConfirms() => SectionedCardSection(
        title: AppLocalizations.of(context)!.required_confirms,
        subtitle: AppLocalizations.of(context)!.n_of_k(
          widget.reqConfirms!.toString(),
          '${widget.custodians!.length}',
        ),
      );

  Widget submitButton() =>
      BlocBuilder<TonWalletPrepareDeployBloc, TonWalletPrepareDeployState>(
        builder: (context, state) => PrimaryElevatedButton(
          onPressed: state.maybeWhen(
            ready: (unsignedMessage, fees) => () => onPressed(
                  message: unsignedMessage,
                  publicKey: widget.publicKey,
                ),
            orElse: () => null,
          ),
          text: AppLocalizations.of(context)!.deploy,
        ),
      );

  Future<void> onPressed({
    required UnsignedMessageWithAdditionalInfo message,
    required String publicKey,
  }) async {
    String? password;

    final isEnabled = context.read<BiometryRepository>().availability;
    final isAvailable = context.read<BiometryRepository>().status;

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
      final password = await context.read<BiometryRepository>().getKeyPassword(
            localizedReason:
                AppLocalizations.of(context)!.authentication_reason,
            publicKey: publicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
  }

  Future<void> pushDeploymentResult({
    required UnsignedMessageWithAdditionalInfo message,
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
            sendingText: '${AppLocalizations.of(context)!.deploying}...',
            successText: AppLocalizations.of(context)!.wallet_deployed,
          ),
        ),
        (_) => false,
      );
}
