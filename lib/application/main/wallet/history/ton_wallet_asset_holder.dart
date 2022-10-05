import 'package:ever_wallet/application/bloc/common/token_currency_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/main/wallet/history/wallet_asset_holder.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_asset_info/show_ton_asset_info.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TonWalletAssetHolder extends StatefulWidget {
  final String address;

  const TonWalletAssetHolder({
    super.key,
    required this.address,
  });

  @override
  _TonWalletAssetHolderState createState() => _TonWalletAssetHolderState();
}

class _TonWalletAssetHolderState extends State<TonWalletAssetHolder> {
  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<String>(
        create: (context) => context
            .read<TonWalletsRepository>()
            .contractStateStream(widget.address)
            .map((e) => e.balance),
        builder: (context, child) {
          final balance = context.watch<AsyncValue<String>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return AsyncValueStreamProvider<Currency?>(
            create: (context) => tokenCurrencyStream(
              context.read<TokenCurrenciesRepository>(),
              kAddressForEverCurrency,
            ),
            builder: (context, child) {
              final currency = context.watch<AsyncValue<Currency?>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

              return WalletAssetHolder(
                icon: Assets.images.ever.svg(
                  width: 36,
                  height: 36,
                ),
                balance: balance != null
                    ? '${balance.toTokens().removeZeroes().formatValue()} $kEverTicker'
                    : '0 $kEverTicker',
                balanceUsdt: currency != null && balance != null
                    ? '\$${(double.parse(balance.toTokens()) * double.parse(currency.price)).truncateToDecimalPlaces(4).toStringAsFixed(4).removeZeroes().formatValue()}'
                    : '\$0',
                onTap: balance != null
                    ? () => showTonAssetInfo(
                          context: context,
                          address: widget.address,
                        )
                    : () {},
              );
            },
          );
        },
      );
}
