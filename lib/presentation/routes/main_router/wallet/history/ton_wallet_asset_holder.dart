import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../design/design.dart';
import '../modals/ton_asset_info/show_ton_asset_info.dart';
import 'wallet_asset_holder.dart';

class TonWalletAssetHolder extends StatefulWidget {
  final String address;
  final bool isExternal;

  const TonWalletAssetHolder({
    Key? key,
    required this.address,
    this.isExternal = false,
  }) : super(key: key);

  @override
  _TonWalletAssetHolderState createState() => _TonWalletAssetHolderState();
}

class _TonWalletAssetHolderState extends State<TonWalletAssetHolder> {
  final bloc = getIt.get<TonWalletInfoBloc>();

  @override
  void initState() {
    bloc.add(TonWalletInfoEvent.load(widget.address));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TonWalletAssetHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      bloc.add(TonWalletInfoEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: bloc,
        builder: (context, state) => WalletAssetHolder(
          name: 'TON',
          balance: state != null ? state.contractState.balance : '0',
          decimals: kTonDecimals,
          icon: Assets.images.ton.svg(),
          onTap: state != null
              ? () => showTonAssetInfo(
                    context: context,
                    address: state.address,
                    isExternal: widget.isExternal,
                  )
              : () {},
        ),
      );
}
