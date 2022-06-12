import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../data/constants.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../providers/common/token_currency_provider.dart';
import '../../../common/constants.dart';
import '../../../common/extensions.dart';
import '../modals/ton_asset_info/show_ton_asset_info.dart';
import 'wallet_asset_holder.dart';

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
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;
          final currency = ref.watch(tokenCurrencyProvider(kAddressForEverCurrency)).asData?.value;

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
}
