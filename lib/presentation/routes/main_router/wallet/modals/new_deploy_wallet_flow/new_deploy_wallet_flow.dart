import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../../../domain/blocs/ton_wallet/ton_wallet_estimate_fees_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_prepare_deploy_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_send_bloc.dart';
import '../../../../../../injection.dart';
import 'new_select_wallet_type_page.dart';

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
      showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => DeployWalletFlow._(
          address: address,
          publicKey: publicKey,
        ),
      );

  @override
  _DeployWalletFlowState createState() => _DeployWalletFlowState();
}

class _DeployWalletFlowState extends State<DeployWalletFlow> {
  final prepareDeployBloc = getIt.get<TonWalletPrepareDeployBloc>();
  final estimateFeesBloc = getIt.get<TonWalletEstimateFeesBloc>();
  final sendBloc = getIt.get<TonWalletSendBloc>();

  @override
  void dispose() {
    super.dispose();
    prepareDeployBloc.close();
    estimateFeesBloc.close();
    sendBloc.close();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => NewSelectWalletTypePage(
            modalContext: context,
            address: widget.address,
            publicKey: widget.publicKey,
          ),
        ),
      );
}
