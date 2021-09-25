import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../domain/blocs/ton_wallet/ton_wallet_deployment_bloc.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_deployment_fees_bloc.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widget/crystal_bottom_sheet.dart';
import '../../../widgets/input_password_modal_body.dart';

part 'deploy_body.dart';
part 'password_body.dart';
part 'result_body.dart';

class DeployWalletFlow extends StatefulWidget {
  final String address;
  final String publicKey;

  const DeployWalletFlow._({
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
        body: DeployWalletFlow._(
          address: address,
          publicKey: publicKey,
        ),
      );

  @override
  _DeployWalletFlowState createState() => _DeployWalletFlowState();
}

class _DeployWalletFlowState extends State<DeployWalletFlow> {
  final _pageController = PageController();
  late TonWalletDeploymentBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt.get<TonWalletDeploymentBloc>(param1: widget.address);
  }

  @override
  void dispose() {
    bloc.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: bloc,
        child: Builder(
          builder: (context) => BlocConsumer<TonWalletDeploymentBloc, TonWalletDeploymentState>(
            listener: (context, state) {
              FocusScope.of(context).unfocus();
              state.maybeMap(
                initial: (_) => _pageController.openAt(0),
                password: (_) => _pageController.openAt(1),
                sending: (_) => _pageController.openAt(2),
                orElse: () => null,
              );
            },
            builder: (context, state) {
              return ModalFlowBase(
                pageController: _pageController,
                activeTitle: state.map(
                  initial: (_) => LocaleKeys.deploy_wallet_modal_available_message.tr(),
                  password: (_) => LocaleKeys.deploy_wallet_modal_password.tr(),
                  success: (_) => LocaleKeys.deploy_wallet_modal_success.tr(),
                  sending: (_) => LocaleKeys.deploy_wallet_modal_deploying.tr(),
                  error: (error) => error.info,
                ),
                layoutBuilder: (context, child) => SafeArea(
                  minimum: const EdgeInsets.symmetric(vertical: 16),
                  child: child,
                ),
                pages: [
                  const DeployBody(),
                  Padding(
                    padding: context.keyboardInsets,
                    child: PasswordBody(publicKey: widget.publicKey),
                  ),
                  const ResultBody(),
                ],
              );
            },
          ),
        ),
      );
}
