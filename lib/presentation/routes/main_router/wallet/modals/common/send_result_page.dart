import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../domain/blocs/ton_wallet/ton_wallet_send_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_title.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';

class SendResultPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String address;
  final UnsignedMessage message;
  final String publicKey;
  final String password;
  final String sendingText;
  final String successText;

  const SendResultPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.message,
    required this.publicKey,
    required this.password,
    required this.sendingText,
    required this.successText,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends ConsumerState<SendResultPage> {
  @override
  void initState() {
    super.initState();
    ref.read(tonWalletSendProvider.notifier).send(
          address: widget.address,
          message: widget.message,
          publicKey: widget.publicKey,
          password: widget.password,
        );
  }

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final value = ref.watch(tonWalletSendProvider);

          return Scaffold(
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
                          title(value),
                          const SizedBox(height: 16),
                          card(value),
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          submitButton(value),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget title(AsyncValue<PendingTransaction> value) => value.when(
        data: (data) => CrystalTitle(
          text: widget.successText,
        ),
        error: (err, st) => CrystalTitle(
          text: err.toString(),
        ),
        loading: () => CrystalTitle(
          text: widget.sendingText,
        ),
      );

  Widget card(AsyncValue<PendingTransaction> value) => value.when(
        data: (data) => animation(
          Assets.animations.done,
        ),
        error: (err, st) => animation(
          Assets.animations.failed,
        ),
        loading: () => animation(
          Assets.animations.money,
        ),
      );

  Widget animation(String name) => Lottie.asset(
        name,
        height: 180,
      );

  Widget submitButton(AsyncValue<PendingTransaction> value) => CustomElevatedButton(
        onPressed: value.when(
          data: (data) => onPressed,
          error: (err, st) => onPressed,
          loading: () => null,
        ),
        text: 'Ok',
      );

  void onPressed() => Navigator.of(widget.modalContext).pop();
}
