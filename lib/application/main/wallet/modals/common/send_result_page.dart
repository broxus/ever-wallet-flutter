import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_send_bloc.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SendResultPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final UnsignedMessageWithAdditionalInfo message;
  final String publicKey;
  final String password;
  final String sendingText;
  final String successText;

  /// Widget that will be built as a body
  final Widget Function(BuildContext modalContext)? resultBuilder;

  const SendResultPage({
    super.key,
    required this.modalContext,
    required this.address,
    required this.message,
    required this.publicKey,
    required this.password,
    required this.sendingText,
    required this.successText,
    this.resultBuilder,
  });

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<SendResultPage> {
  @override
  Widget build(BuildContext context) => BlocProvider<TonWalletSendBloc>(
        key: ValueKey(widget.address),
        create: (context) => TonWalletSendBloc(
          context.read<TonWalletsRepository>(),
          context.read<KeysRepository>(),
          widget.address,
        )..add(
            TonWalletSendEvent.send(
              unsignedMessage: widget.message,
              publicKey: widget.publicKey,
              password: widget.password,
            ),
          ),
        child: BlocBuilder<TonWalletSendBloc, TonWalletSendState>(
          builder: (context, state) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: widget.resultBuilder?.call(widget.modalContext) ??
                SafeArea(
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
                              title(state),
                              const Gap(16),
                              card(state),
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
                ),
          ),
        ),
      );

  Widget title(TonWalletSendState state) => state.maybeWhen(
        ready: (transaction) => CrystalTitle(
          text: widget.successText,
        ),
        error: (error) => CrystalTitle(
          text: error,
        ),
        orElse: () => CrystalTitle(
          text: widget.sendingText,
        ),
      );

  Widget card(TonWalletSendState state) => state.maybeWhen(
        ready: (transaction) => animation(
          Assets.animations.done,
        ),
        error: (error) => animation(
          Assets.animations.failed,
        ),
        orElse: () => animation(
          Assets.animations.money,
        ),
      );

  Widget animation(String name) => Lottie.asset(
        name,
        height: 180,
      );

  Widget submitButton() => PrimaryElevatedButton(
        onPressed: onPressed,
        text: AppLocalizations.of(context)!.ok,
      );

  void onPressed() => Navigator.of(widget.modalContext).pop();
}
