import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../data/constants.dart';
import '../../../../providers/common/network_type_provider.dart';
import '../../../../providers/common/token_currency_provider.dart';
import '../../../common/constants.dart';
import '../../../common/extensions.dart';
import '../../../common/widgets/ton_asset_icon.dart';
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
          final isEver = ref.watch(networkTypeProvider).asData?.value == 'Ever';

          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;
          final currency = ref
              .watch(
                tokenCurrencyProvider(
                  isEver ? kAddressForEverCurrency : kAddressForVenomCurrency,
                ),
              )
              .asData
              ?.value;

          final ticker = isEver ? kEverTicker : kVenomTicker;

          return WalletAssetHolder(
            icon: const TonAssetIcon(),
            balance: tonWalletInfo != null
                ? '${tonWalletInfo.contractState.balance.toTokens().removeZeroes().formatValue()} $ticker'
                : '0 $ticker',
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
