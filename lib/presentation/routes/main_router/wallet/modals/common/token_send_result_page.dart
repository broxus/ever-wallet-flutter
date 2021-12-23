import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../domain/blocs/ton_wallet/ton_wallet_send_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_title.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';

class TokenSendResultPage extends StatefulWidget {
  final BuildContext modalContext;
  final String owner;
  final String rootTokenContract;
  final UnsignedMessage message;
  final String publicKey;
  final String password;
  final String sendingText;
  final String successText;

  const TokenSendResultPage({
    Key? key,
    required this.modalContext,
    required this.owner,
    required this.rootTokenContract,
    required this.message,
    required this.publicKey,
    required this.password,
    required this.sendingText,
    required this.successText,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<TokenSendResultPage> {
  final bloc = getIt.get<TonWalletSendBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(
      TonWalletSendEvent.send(
        address: widget.owner,
        message: widget.message,
        publicKey: widget.publicKey,
        password: widget.password,
      ),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
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
                      title(),
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
        ),
      );

  Widget title() => BlocBuilder<TonWalletSendBloc, TonWalletSendState>(
        bloc: bloc,
        builder: (context, state) => state.when(
          initial: () => CrystalTitle(
            text: widget.sendingText,
          ),
          success: () => CrystalTitle(
            text: widget.successText,
          ),
          error: (exception) => CrystalTitle(
            text: exception.toString(),
          ),
        ),
      );

  Widget card() => BlocBuilder<TonWalletSendBloc, TonWalletSendState>(
        bloc: bloc,
        builder: (context, state) => state.when(
          initial: () => animation(
            Assets.animations.money,
          ),
          success: () => animation(
            Assets.animations.done,
          ),
          error: (exception) => animation(
            Assets.animations.failed,
          ),
        ),
      );

  Widget animation(String name) => Lottie.asset(
        name,
        height: 180,
      );

  Widget submitButton() => BlocBuilder<TonWalletSendBloc, TonWalletSendState>(
        bloc: bloc,
        builder: (context, state) => CustomElevatedButton(
          onPressed: state.maybeWhen(
            success: () => onPressed,
            error: (_) => onPressed,
            orElse: () => null,
          ),
          text: 'Ok',
        ),
      );

  void onPressed() => Navigator.of(widget.modalContext).pop();
}
