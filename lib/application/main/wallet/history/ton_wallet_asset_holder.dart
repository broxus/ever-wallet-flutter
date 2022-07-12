import 'package:ever_wallet/application/bloc/common/token_currency_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/main/wallet/history/wallet_asset_holder.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_asset_info/show_ton_asset_info.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TonWalletAssetHolder extends StatefulWidget {
  final String address;

  const TonWalletAssetHolder({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _TonWalletAssetHolderState createState() => _TonWalletAssetHolderState();
}

class _TonWalletAssetHolderState extends State<TonWalletAssetHolder> {
  @override
  Widget build(BuildContext context) => StreamProvider<AsyncValue<TonWalletInfo?>>(
        create: (context) => context
            .read<TonWalletsRepository>()
            .getInfoStream(widget.address)
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return StreamProvider<AsyncValue<Currency?>>(
            create: (context) => tokenCurrencyStream(
              context.read<TokenCurrenciesRepository>(),
              kAddressForEverCurrency,
            ).map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
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
                balance: tonWalletInfo != null
                    ? '${tonWalletInfo.contractState.balance.toTokens().removeZeroes().formatValue()} $kEverTicker'
                    : '0 $kEverTicker',
                balanceUsdt: currency != null && tonWalletInfo != null
                    ? '\$${(double.parse(tonWalletInfo.contractState.balance.toTokens()) * double.parse(currency.price)).truncateToDecimalPlaces(4).toStringAsFixed(4).removeZeroes().formatValue()}'
                    : '\$0',
                onTap: tonWalletInfo != null
                    ? () => showTonAssetInfo(
                          context: context,
                          address: tonWalletInfo.address,
                        )
                    : () {},
              );
            },
          );
        },
      );
}
