import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/utils.dart';
import '../modals/asset_observer/ton_asset_observer.dart';
import 'wallet_asset_holder.dart';

class TonWalletAssetHolder extends StatefulWidget {
  final TonWallet tonWallet;

  const TonWalletAssetHolder({
    Key? key,
    required this.tonWallet,
  }) : super(key: key);

  @override
  _TonWalletAssetHolderState createState() => _TonWalletAssetHolderState();
}

class _TonWalletAssetHolderState extends State<TonWalletAssetHolder> {
  late final TonWalletInfoBloc bloc;

  @override
  void initState() {
    bloc = getIt.get<TonWalletInfoBloc>(param1: widget.tonWallet);
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          ready: (address, contractState, walletType, details, publicKey) => WalletAssetHolder(
            name: 'TON',
            balance: contractState.balance.floorValue(),
            icon: getTonAssetIcon(),
            onTap: () => TonAssetObserver.open(
              context: context,
              tonWallet: widget.tonWallet,
            ),
          ),
          orElse: () => const SizedBox(),
        ),
      );
}
