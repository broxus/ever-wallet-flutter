import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/token_wallet/token_wallet_info_bloc.dart';
import '../../../../injection.dart';
import '../../../design/utils.dart';
import '../modals/asset_observer/token_asset_observer.dart';
import 'wallet_asset_holder.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final String owner;
  final String rootTokenContract;

  const TokenWalletAssetHolder({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
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
  Widget build(BuildContext context) => BlocBuilder<TokenWalletInfoBloc, TokenWalletInfoState?>(
        bloc: bloc,
        builder: (context, state) => state != null
            ? WalletAssetHolder(
                name: state.symbol.name,
                balance: state.balance,
                icon: state.logoURI != null
                    ? getTokenAssetIcon(state.logoURI!)
                    : getGravatarIcon(state.symbol.name.hashCode),
                onTap: () => TokenAssetObserver.open(
                  context: context,
                  owner: state.owner,
                  rootTokenContract: state.symbol.rootTokenContract,
                ),
              )
            : const SizedBox(),
      );
}
