import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../providers/token_wallet/token_wallet_info_provider.dart';
import '../../../../providers/common/token_currency_provider.dart';
import '../../../common/extensions.dart';
import '../../../common/widgets/token_address_generated_icon.dart';
import '../../../common/widgets/token_asset_icon.dart';
import '../modals/token_asset_info/show_token_asset_info.dart';
import 'wallet_asset_holder.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String symbol;
  final int decimals;
  final TokenWalletVersion version;
  final String? logoURI;

  const TokenWalletAssetHolder({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
    required this.symbol,
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
          final currency = ref.watch(tokenCurrencyProvider(widget.rootTokenContract)).asData?.value;

          return WalletAssetHolder(
            icon: widget.logoURI != null
                ? TokenAssetIcon(
                    logoURI: widget.logoURI!,
                    version: widget.version,
                  )
                : TokenAddressGeneratedIcon(
                    address: widget.rootTokenContract,
                    version: widget.version,
                  ),
            balance: tokenWalletInfo != null
                ? '${tokenWalletInfo.balance.toTokens(widget.decimals).removeZeroes().formatValue()} ${widget.symbol}'
                : '0 ${widget.symbol}',
            balanceUsdt: currency != null && tokenWalletInfo != null
                ? '\$${(double.parse(tokenWalletInfo.balance.toTokens(widget.decimals)) * double.parse(currency.price)).truncateToDecimalPlaces(4).toStringAsFixed(4).removeZeroes().formatValue()}'
                : '\$0',
            onTap: tokenWalletInfo != null
                ? () => showTokenAssetInfo(
                      context: context,
                      owner: widget.owner,
                      rootTokenContract: widget.rootTokenContract,
                      logoURI: widget.logoURI,
                    )
                : () {},
          );
        },
      );
}
