import 'package:ever_wallet/application/bloc/common/token_currency_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/token_address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/token_asset_icon.dart';
import 'package:ever_wallet/application/main/wallet/history/wallet_asset_holder.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_asset_info/show_token_asset_info.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class TokenWalletAssetHolder extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String name;
  final String symbol;
  final int decimals;
  final TokenWalletVersion version;
  final String? logoURI;

  const TokenWalletAssetHolder({
    super.key,
    required this.owner,
    required this.rootTokenContract,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.version,
    this.logoURI,
  });

  @override
  _TokenWalletAssetHolderState createState() => _TokenWalletAssetHolderState();
}

class _TokenWalletAssetHolderState extends State<TokenWalletAssetHolder> {
  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<String>(
        create: (context) => context
            .read<TokenWalletsRepository>()
            .balanceStream(owner: widget.owner, rootTokenContract: widget.rootTokenContract),
        builder: (context, child) {
          final balance = context.watch<AsyncValue<String>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return AsyncValueStreamProvider<Currency?>(
            create: (context) => tokenCurrencyStream(
              context.read<TokenCurrenciesRepository>(),
              widget.rootTokenContract,
            ),
            builder: (context, child) {
              final currency = context.watch<AsyncValue<Currency?>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

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
                balance: balance != null
                    ? '${balance.toTokens(widget.decimals).removeZeroes().formatValue()} ${widget.symbol}'
                    : '0 ${widget.symbol}',
                balanceUsdt: currency != null && balance != null
                    ? '\$${(double.parse(balance.toTokens(widget.decimals)) * double.parse(currency.price)).truncateToDecimalPlaces(4).toStringAsFixed(4).removeZeroes().formatValue()}'
                    : '\$0',
                onTap: balance != null
                    ? () => showTokenAssetInfo(
                          context: context,
                          owner: widget.owner,
                          rootTokenContract: widget.rootTokenContract,
                          name: widget.name,
                          symbol: widget.symbol,
                          decimals: widget.decimals,
                          version: widget.version,
                          logoURI: widget.logoURI,
                        )
                    : () {},
              );
            },
          );
        },
      );
}
