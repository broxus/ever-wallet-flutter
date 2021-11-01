import 'package:crystal/domain/models/ton_wallet_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../modals/asset_observer/ton_asset_observer.dart';
import 'wallet_asset_holder.dart';

class TonWalletAssetHolder extends StatefulWidget {
  final String address;

  const TonWalletAssetHolder({
    Key? key,
    required this.address,
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
          balance: state != null ? state.contractState.balance : '0.0',
          icon: Image.asset(Assets.images.ton.path),
          onTap: state != null
              ? () => TonAssetObserver.open(
                    context: context,
                    address: state.address,
                  )
              : () {},
        ),
      );
}
