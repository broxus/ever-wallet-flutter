import 'package:crystal/domain/blocs/biometry/biometry_info_bloc.dart';
import 'package:crystal/domain/blocs/biometry/biometry_password_data_bloc.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/ton_wallet/ton_wallet_fees_bloc.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_transfer_bloc.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widget/crystal_bottom_sheet.dart';
import '../../../widgets/input_password_modal_body.dart';

part 'confirm_body.dart';
part 'loader_body.dart';
part 'password_body.dart';
part 'receiver_body.dart';

class SendTransactionFlow extends StatefulWidget {
  final String address;
  final String publicKey;

  const SendTransactionFlow._({
    required this.address,
    required this.publicKey,
  });

  static Future<void> start({
    required BuildContext context,
    required String address,
    required String publicKey,
  }) =>
      showCrystalBottomSheet(
        context,
        draggable: false,
        padding: EdgeInsets.zero,
        wrapIntoAnimatedSize: false,
        avoidBottomInsets: false,
        body: SendTransactionFlow._(
          address: address,
          publicKey: publicKey,
        ),
      );

  @override
  _SendTransactionFlowState createState() => _SendTransactionFlowState();
}

class _SendTransactionFlowState extends State<SendTransactionFlow> {
  final _clipboard = ValueNotifier<String?>(null);
  final _pageController = PageController();
  late TonWalletTransferBloc _bloc;

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
    _bloc = getIt.get<TonWalletTransferBloc>(param1: widget.address);
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
          builder: (context) => BlocConsumer<TonWalletTransferBloc, TonWalletTransferState>(
            listener: (context, state) {
              FocusScope.of(context).unfocus();
              state.maybeMap(
                initial: (_) async => _pageController.openAt(0),
                messagePrepared: (_) async => _pageController.openAt(1),
                password: (_) async {
                  String? password;

                  final biometryInfoBloc = context.read<BiometryInfoBloc>();
                  final biometryPasswordDataBloc = getIt.get<BiometryPasswordDataBloc>();

                  if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
                    biometryPasswordDataBloc.add(BiometryPasswordDataEvent.getKeyPassword(widget.publicKey));

                    final state = await biometryPasswordDataBloc.stream.first;

                    password = state.maybeWhen(
                      ready: (password) => password,
                      orElse: () => null,
                    );

                    if (password != null) {
                      _bloc.add(TonWalletTransferEvent.send(password));
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
                sending: (_) async => _pageController.openAt(3),
                orElse: () async => null,
              );
            },
            builder: (context, state) {
              final balance = state.maybeWhen(orElse: () => null, initial: (balance) => balance);
              return ModalFlowBase(
                onWillPop: () async {
                  if (_pageController.page == 1) {
                    _bloc.add(
                      const TonWalletTransferEvent.backToInitial(),
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
                      child: _EnterAddressBody(clipboard: _clipboard, balance: balance),
                    ),
                  ),
                  _ConfirmBody(
                    onBack: () => _bloc.add(
                      const TonWalletTransferEvent.backToInitial(),
                    ),
                  ),
                  Padding(
                    padding: context.keyboardInsets,
                    child: _PasswordBody(publicKey: widget.publicKey),
                  ),
                  const _LoaderBody(),
                ],
              );
            },
          ),
        ),
      );
}
