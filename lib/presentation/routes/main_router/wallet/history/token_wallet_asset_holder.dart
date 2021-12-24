import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/token_wallet/token_wallet_info_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../design/widgets/address_generated_icon.dart';
import '../../../../design/widgets/token_asset_icon.dart';
import '../modals/token_asset_info/show_token_asset_info.dart';
import 'wallet_asset_holder.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String? icon;

  const TokenWalletAssetHolder({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
    this.icon,
  }) : super(key: key);

  @override
  _TokenWalletAssetHolderState createState() => _TokenWalletAssetHolderState();
}

class _TokenWalletAssetHolderState extends State<TokenWalletAssetHolder> {
  final bloc = getIt.get<TokenWalletInfoBloc>();

  @override
  void initState() {
    bloc.add(
      TokenWalletInfoEvent.load(
        owner: widget.owner,
        rootTokenContract: widget.rootTokenContract,
      ),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TokenWalletAssetHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.owner != widget.owner || oldWidget.rootTokenContract != widget.rootTokenContract) {
      bloc.add(
        TokenWalletInfoEvent.load(
          owner: widget.owner,
          rootTokenContract: widget.rootTokenContract,
        ),
      );
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
          icon: widget.icon != null
              ? TokenAssetIcon(
                  icon: widget.icon!,
                )
              : AddressGeneratedIcon(
                  address: widget.rootTokenContract,
                ),
          onTap: state != null
              ? () => showTokenAssetInfo(
                    context: context,
                    owner: state.owner,
                    rootTokenContract: widget.rootTokenContract,
                    icon: widget.icon,
                  )
              : () {},
        ),
      );
}
