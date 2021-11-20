import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/token_wallet/token_wallet_info_bloc.dart';
import '../../../../../../../../domain/models/token_wallet_info.dart';
import '../../../../../../../../injection.dart';
import '../../../../design/widgets/asset_icon.dart';
import '../modals/asset_observer/token_asset_observer.dart';
import 'wallet_asset_holder.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String? svgIcon;
  final List<int>? gravatarIcon;

  const TokenWalletAssetHolder({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
    this.svgIcon,
    this.gravatarIcon,
  }) : super(key: key);

  @override
  _TokenWalletAssetHolderState createState() => _TokenWalletAssetHolderState();
}

class _TokenWalletAssetHolderState extends State<TokenWalletAssetHolder> {
  final bloc = getIt.get<TokenWalletInfoBloc>();

  @override
  void initState() {
    bloc.add(TokenWalletInfoEvent.load(
      owner: widget.owner,
      rootTokenContract: widget.rootTokenContract,
    ));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TokenWalletAssetHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.owner != widget.owner || oldWidget.rootTokenContract != widget.rootTokenContract) {
      bloc.add(TokenWalletInfoEvent.load(
        owner: widget.owner,
        rootTokenContract: widget.rootTokenContract,
      ));
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TokenWalletInfoBloc, TokenWalletInfo?>(
        bloc: bloc,
        builder: (context, state) => WalletAssetHolder(
          name: state != null ? state.symbol.name : '',
          balance: state != null ? state.balance : '0',
          decimals: state != null ? state.symbol.decimals : kTonDecimals,
          icon: AssetIcon(
            svgIcon: widget.svgIcon,
            gravatarIcon: widget.gravatarIcon,
          ),
          onTap: state != null
              ? () => TokenAssetObserver.open(
                    context: context,
                    owner: state.owner,
                    rootTokenContract: state.symbol.rootTokenContract,
                    svgIcon: widget.svgIcon,
                    gravatarIcon: widget.gravatarIcon,
                  )
              : () {},
        ),
      );
}
