import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../domain/blocs/token_wallet/token_wallet_info_provider.dart';
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
  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final tokenWalletInfo = ref
              .watch(
                tokenWalletInfoProvider(
                  Tuple2(widget.owner, widget.rootTokenContract),
                ),
              )
              .asData
              ?.value;

          return WalletAssetHolder(
            name: tokenWalletInfo != null ? tokenWalletInfo.symbol.name : '',
            balance: tokenWalletInfo != null ? tokenWalletInfo.balance : '0',
            decimals: tokenWalletInfo != null ? tokenWalletInfo.symbol.decimals : kTonDecimals,
            icon: widget.icon != null
                ? TokenAssetIcon(
                    icon: widget.icon!,
                  )
                : AddressGeneratedIcon(
                    address: widget.rootTokenContract,
                  ),
            onTap: tokenWalletInfo != null
                ? () => showTokenAssetInfo(
                      context: context,
                      owner: tokenWalletInfo.owner,
                      rootTokenContract: widget.rootTokenContract,
                      icon: widget.icon,
                    )
                : () {},
          );
        },
      );
}
