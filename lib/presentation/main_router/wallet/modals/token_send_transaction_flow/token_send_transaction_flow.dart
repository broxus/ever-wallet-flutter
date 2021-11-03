import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/biometry/biometry_get_password_bloc.dart';
import '../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../../domain/blocs/token_wallet/token_wallet_fees_bloc.dart';
import '../../../../../domain/blocs/token_wallet/token_wallet_transfer_bloc.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widget/crystal_bottom_sheet.dart';
import '../../../widgets/input_password_modal_body.dart';

part 'confirm_body.dart';
part 'loader_body.dart';
part 'password_body.dart';
part 'receiver_body.dart';

class TokenSendTransactionFlow extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String ownerPublicKey;

  const TokenSendTransactionFlow._({
    required this.owner,
    required this.rootTokenContract,
    required this.ownerPublicKey,
  });

  static Future<void> start({
    required BuildContext context,
    required String owner,
    required String rootTokenContract,
    required String ownerPublicKey,
  }) =>
      showCrystalBottomSheet(
        context,
        draggable: false,
        padding: EdgeInsets.zero,
        wrapIntoAnimatedSize: false,
        avoidBottomInsets: false,
        body: TokenSendTransactionFlow._(
          owner: owner,
          rootTokenContract: rootTokenContract,
          ownerPublicKey: ownerPublicKey,
        ),
      );

  @override
  _TokenSendTransactionFlowState createState() => _TokenSendTransactionFlowState();
}

class _TokenSendTransactionFlowState extends State<TokenSendTransactionFlow> {
  final _clipboard = ValueNotifier<String?>(null);

  final _pageController = PageController();
  late TokenWalletTransferBloc _bloc;

  Future<void> _clipboardListener() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    _clipboard.value = clipboard?.text;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clipboardListener();
  }

  @override
  void initState() {
    super.initState();
    _bloc = getIt.get<TokenWalletTransferBloc>(
      param1: widget.owner,
      param2: widget.rootTokenContract,
    );
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) => _clipboardListener());
  }

  @override
  void dispose() {
    _bloc.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _bloc,
        child: Builder(
          builder: (context) => BlocConsumer<TokenWalletTransferBloc, TokenWalletTransferState>(
            listener: (context, state) {
              FocusScope.of(context).unfocus();
              state.maybeMap(
                initial: (_) => _pageController.openAt(0),
                messagePrepared: (_) => _pageController.openAt(1),
                password: (_) async {
                  String? password;

                  final biometryInfoBloc = context.read<BiometryInfoBloc>();
                  final biometryPasswordDataBloc = getIt.get<BiometryGetPasswordBloc>();

                  if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
                    biometryPasswordDataBloc.add(BiometryGetPasswordEvent.get(
                      localizedReason: 'Please authenticate to interact with wallet',
                      publicKey: widget.ownerPublicKey,
                    ));

                    password = await biometryPasswordDataBloc.stream
                        .firstWhere((e) => e is BiometryGetPasswordStateSuccess)
                        .then((value) => value as BiometryGetPasswordStateSuccess)
                        .then((value) => value.password);

                    if (password != null) {
                      _bloc.add(TokenWalletTransferEvent.send(password));
                    } else {
                      _pageController.openAt(2);
                    }

                    Future.delayed(const Duration(seconds: 1), () async {
                      biometryPasswordDataBloc.close();
                    });
                  } else {
                    _pageController.openAt(2);
                  }
                },
                sending: (_) => _pageController.openAt(3),
                orElse: () => null,
              );
            },
            builder: (context, state) {
              final balance = state.maybeWhen(orElse: () => null, initial: (balance, _) => balance);
              final currency = state.maybeWhen(orElse: () => null, initial: (_, currency) => currency);

              return ModalFlowBase(
                onWillPop: () async {
                  if (_pageController.page == 1) {
                    _bloc.add(
                      const TokenWalletTransferEvent.backToInitial(),
                    );
                    return false;
                  }
                  return true;
                },
                pageController: _pageController,
                activeTitle: state.map(
                  initial: (_) => LocaleKeys.send_transaction_modal_input_title.tr(),
                  messagePrepared: (_) => LocaleKeys.send_transaction_modal_confirm_title.tr(),
                  password: (_) => LocaleKeys.send_transaction_modal_password.tr(),
                  success: (_) => LocaleKeys.send_transaction_modal_success.tr(),
                  sending: (_) => LocaleKeys.send_transaction_modal_sending.tr(),
                  error: (error) => error.info,
                ),
                layoutBuilder: (context, child) => SafeArea(
                  minimum: const EdgeInsets.symmetric(vertical: 16),
                  child: child,
                ),
                pages: [
                  KeepAliveWidget(
                    child: Padding(
                      padding: context.keyboardInsets,
                      child: _EnterAddressBody(
                        clipboard: _clipboard,
                        balance: balance,
                        currency: currency,
                      ),
                    ),
                  ),
                  _ConfirmBody(
                    onBack: () => _bloc.add(
                      const TokenWalletTransferEvent.backToInitial(),
                    ),
                  ),
                  Padding(
                    padding: context.keyboardInsets,
                    child: _PasswordBody(publicKey: widget.ownerPublicKey),
                  ),
                  const _LoaderBody(),
                ],
              );
            },
          ),
        ),
      );
}
