import 'package:ever_wallet/application/bloc/common/token_currency_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/token_address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/token_asset_icon.dart';
import 'package:ever_wallet/application/main/wallet/history/wallet_asset_holder.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_asset_info/show_token_asset_info.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/token_wallet_info.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) => StreamProvider<AsyncValue<TokenWalletInfo?>>(
        create: (context) => context
            .read<TokenWalletsRepository>()
            .getInfoStream(owner: widget.owner, rootTokenContract: widget.rootTokenContract)
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final tokenWalletInfo = context.watch<AsyncValue<TokenWalletInfo?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return StreamProvider<AsyncValue<Currency?>>(
            create: (context) => tokenCurrencyStream(
              context.read<TokenCurrenciesRepository>(),
              widget.rootTokenContract,
            ).map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
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
        },
      );
}
