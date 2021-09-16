import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/token_wallet/token_wallet_info_bloc.dart';
import '../../../../injection.dart';
import '../../../design/utils.dart';
import '../modals/asset_observer/token_asset_observer.dart';
import 'wallet_asset_holder.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final TokenWallet tokenWallet;
  final String? logoURI;

  const TokenWalletAssetHolder({
    Key? key,
    required this.tokenWallet,
    required this.logoURI,
  }) : super(key: key);

  @override
  _TokenWalletAssetHolderState createState() => _TokenWalletAssetHolderState();
}

class _TokenWalletAssetHolderState extends State<TokenWalletAssetHolder> {
  late final TokenWalletInfoBloc bloc;

  @override
  void initState() {
    bloc = getIt.get<TokenWalletInfoBloc>(
      param1: widget.tokenWallet,
      param2: widget.logoURI,
    );
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TokenWalletInfoBloc, TokenWalletInfoState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          ready: (logoURI, address, balance, contractState, owner, symbol, version) {
            final icon = logoURI != null ? getTokenAssetIcon(logoURI) : getRandomTokenAssetIcon(symbol.name.hashCode);

            return WalletAssetHolder(
              name: symbol.name,
              balance: balance,
              icon: icon,
              onTap: () => TokenAssetObserver.open(
                context: context,
                tokenWallet: widget.tokenWallet,
                logoURI: logoURI,
              ),
            );
          },
          orElse: () => const SizedBox(),
        ),
      );
}
