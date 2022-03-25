import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../providers/token_wallet/token_wallet_info_provider.dart';
import '../../../common/widgets/token_address_generated_icon.dart';
import '../../../common/widgets/token_asset_icon.dart';
import '../modals/token_asset_info/show_token_asset_info.dart';
import 'wallet_asset_holder.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String name;
  final int decimals;
  final TokenWalletVersion version;
  final String? logoURI;

  const TokenWalletAssetHolder({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
    required this.name,
    required this.decimals,
    required this.version,
    this.logoURI,
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
            name: widget.name,
            balance: tokenWalletInfo != null ? tokenWalletInfo.balance : '0',
            decimals: widget.decimals,
            icon: widget.logoURI != null
                ? TokenAssetIcon(
                    logoURI: widget.logoURI!,
                    version: widget.version,
                  )
                : TokenAddressGeneratedIcon(
                    address: widget.rootTokenContract,
                    version: widget.version,
                  ),
            onTap: () => showTokenAssetInfo(
              context: context,
              owner: widget.owner,
              rootTokenContract: widget.rootTokenContract,
              logoURI: widget.logoURI,
            ),
          );
        },
      );
}
