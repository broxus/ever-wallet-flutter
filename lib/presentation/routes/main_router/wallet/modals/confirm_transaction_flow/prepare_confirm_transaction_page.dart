import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../domain/blocs/public_keys_labels_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../../logger.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_dropdown_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/modal_header.dart';
import 'confirm_transaction_info_page.dart';

class PrepareConfirmTransactionPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final List<String> publicKeys;
  final String transactionId;
  final String destination;
  final String amount;
  final String? comment;

  const PrepareConfirmTransactionPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKeys,
    required this.transactionId,
    required this.destination,
    required this.amount,
    this.comment,
  }) : super(key: key);

  @override
  _PrepareConfirmTransactionPageState createState() => _PrepareConfirmTransactionPageState();
}

class _PrepareConfirmTransactionPageState extends State<PrepareConfirmTransactionPage> {
  late final ValueNotifier<String> publicKeyNotifier;
  final bloc = getIt.get<TonWalletInfoBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(TonWalletInfoEvent.load(widget.address));
    publicKeyNotifier = ValueNotifier<String>(widget.publicKeys.first);
  }

  @override
  void dispose() {
    publicKeyNotifier.dispose();
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
                Column(
                  children: [
                    ModalHeader(
                      text: 'Confirm transaction',
                      onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            dropdownButton(),
                            const SizedBox(height: 8),
                            balance(),
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  Widget dropdownButton() => BlocBuilder<PublicKeysLabelsBloc, Map<String, String>>(
        bloc: context.watch<PublicKeysLabelsBloc>(),
        builder: (context, state) => ValueListenableBuilder<String>(
          valueListenable: publicKeyNotifier,
          builder: (context, value, child) => CustomDropdownButton<String>(
            items: widget.publicKeys
                .map(
                  (e) => Tuple2(
                    e,
                    state[e] != null ? '${state[e]} (${e.ellipsePublicKey()})' : e.ellipsePublicKey(),
                  ),
                )
                .toList(),
            value: value,
            onChanged: (value) {
              if (value != null) {
                publicKeyNotifier.value = value;
              }
            },
          ),
        ),
      );

  Widget balance() => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: bloc,
        builder: (context, state) => Text(
          'Your balance: ${state?.contractState.balance.toTokens().removeZeroes() ?? '0'} TON',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      );

  Widget submitButton() => ValueListenableBuilder<String>(
        valueListenable: publicKeyNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: () => onPressed(value),
          text: 'Next',
        ),
      );

  void onPressed(String publicKey) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            try {
              final a = ConfirmTransactionInfoPage(
                modalContext: widget.modalContext,
                address: widget.address,
                publicKey: publicKey,
                transactionId: widget.transactionId,
                destination: widget.destination,
                amount: widget.amount,
                comment: widget.comment,
              );

              return a;
            } catch (err, st) {
              logger.e(err, err, st);
              rethrow;
            }
          },
        ),
      );
}
