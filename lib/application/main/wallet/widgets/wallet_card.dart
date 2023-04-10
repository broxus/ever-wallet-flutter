import 'package:auto_size_text/auto_size_text.dart';
import 'package:ever_wallet/application/bloc/common/account_overall_balance_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/animated_appearance.dart';
import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:ever_wallet/application/common/widgets/wallet_card_selectable_field.dart';
import 'package:ever_wallet/application/main/wallet/widgets/more_button.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class WalletCard extends StatelessWidget {
  final String address;
  final String publicKey;
  final WalletType walletType;

  const WalletCard({
    super.key,
    required this.address,
    required this.publicKey,
    required this.walletType,
  });

  @override
  Widget build(BuildContext context) => AnimatedAppearance(
        child: Stack(
          children: [
            Container(
              height: 200,
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: [0, 0.45],
                  colors: [
                    Color(0xFFA6AEBD),
                    CrystalColor.background,
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  gradient: LinearGradient(
                    begin: const Alignment(-5, 2),
                    end: Alignment.topRight,
                    stops: const [0, 0.75],
                    colors: [
                      Colors.white.withOpacity(0.1),
                      CrystalColor.background,
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 17,
                      child: info(context),
                    ),
                    Expanded(flex: 6, child: pattern()),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: MoreButton(
                address: address,
                publicKey: publicKey,
              ),
            ),
          ],
        ),
      );

  Widget pattern() => ColoredBox(
        color: const Color(0xFFCDF8E4),
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC4C5EB), Color(0xFFBF70E6)],
          ).createShader(rect),
          blendMode: BlendMode.srcATop,
          child: Image.asset(
            Assets.images.accountCardPattern.path,
            color: Colors.white,
            fit: BoxFit.cover,
          ),
        ),
      );

  Widget info(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 23, left: 23, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AsyncValueStreamProvider<AssetsList>(
              create: (context) => context
                  .read<AccountsRepository>()
                  .accountsStream
                  .expand((e) => e)
                  .where((e) => e.address == address),
              builder: (context, child) {
                final accountInfo = context.watch<AsyncValue<AssetsList>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return accountInfo != null
                    ? AutoSizeText(
                        accountInfo.name,
                        maxLines: 1,
                        maxFontSize: 16,
                        style: const TextStyle(
                          fontSize: 16,
                          letterSpacing: 0.75,
                          color: CrystalColor.fontLight,
                        ),
                      )
                    : const SizedBox();
              },
            ),
            const Gap(8),
            StreamProvider<AsyncValue<TonWallet?>>(
              create: (context) => context
                  .read<TonWalletsRepository>()
                  .getTonWalletStream(address)
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
              builder: (context, child) {
                final tonWalletInfo = context.watch<AsyncValue<TonWallet?>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tonWalletInfo != null)
                      namedField(
                        name: AppLocalizations.of(context)!.public_key,
                        value: tonWalletInfo.publicKey,
                        ellipsedValue: tonWalletInfo.publicKey.ellipsePublicKey(),
                      )
                    else
                      namedField(
                        name: AppLocalizations.of(context)!.public_key,
                      ),
                    if (tonWalletInfo != null)
                      namedField(
                        name: AppLocalizations.of(context)!.address,
                        value: tonWalletInfo.address,
                        ellipsedValue: tonWalletInfo.address.ellipseAddress(),
                      )
                    else
                      namedField(
                        name: AppLocalizations.of(context)!.address,
                      ),
                    if (tonWalletInfo != null)
                      TransportTypeBuilderWidget(
                        builder: (context, isEver) {
                          return namedField(
                            name: AppLocalizations.of(context)!.type,
                            value: tonWalletInfo.walletType.name(isEver),
                            isSelectable: false,
                          );
                        },
                      )
                    else
                      namedField(
                        name: AppLocalizations.of(context)!.type,
                        isSelectable: false,
                      )
                  ],
                );
              },
            ),
            const Spacer(),
            AsyncValueStreamProvider<bool>(
              create: (context) => context
                  .read<AccountsRepository>()
                  .externalAccountsStream
                  .map((e) => e.values.expand((e) => e).any((e) => e == address)),
              builder: (context, child) {
                final isExternal = context.watch<AsyncValue<bool>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => false,
                    );

                return isExternal ? externalAccountLabel(context) : const SizedBox();
              },
            ),
            const Spacer(flex: 2),
            AsyncValueStreamProvider<double>(
              create: (context) => accountOverallBalanceStream(
                context.read<AccountsRepository>(),
                context.read<TransportRepository>(),
                context.read<TonWalletsRepository>(),
                context.read<TokenWalletsRepository>(),
                context.read<TokenCurrenciesRepository>(),
                address,
              ),
              builder: (context, child) {
                final balanceUsdt = context.watch<AsyncValue<double>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return balanceUsdt != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: balance(
                          balanceUsdt
                              .truncateToDecimalPlaces(4)
                              .toStringAsFixed(4)
                              .removeZeroes()
                              .formatValue(),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ],
        ),
      );

  Widget externalAccountLabel(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.iconMultisig.svg(),
          const Gap(8),
          Text(
            AppLocalizations.of(context)!.external_account,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );

  Widget namedField({
    required String name,
    String? value,
    String? ellipsedValue,
    bool isSelectable = true,
    bool disabled = false,
  }) =>
      Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 0.75,
              color: CrystalColor.secondary,
            ),
          ),
          const Gap(8),
          Flexible(
            child: value == null && ellipsedValue == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: shimmer(),
                  )
                : isSelectable
                    ? WalletCardSelectableField(
                        value: value!,
                        text: ellipsedValue!,
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          value!,
                          maxLines: 1,
                          style: const TextStyle(
                            letterSpacing: 0.75,
                            color: CrystalColor.secondary,
                          ),
                        ),
                      ),
          ),
        ],
      );

  Widget balance(String balance) {
    final parts = balance.split('.');

    return AutoSizeText.rich(
      TextSpan(
        text: '\$${parts.first}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0.75,
          fontWeight: FontWeight.bold,
        ),
        children: parts.length != 1
            ? [
                TextSpan(
                  text: '.${parts.last}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0.75,
                    fontWeight: FontWeight.normal,
                  ),
                )
              ]
            : null,
      ),
      maxLines: 1,
      minFontSize: 10,
    );
  }

  Widget shimmer({
    double height = 16,
    double width = 80,
  }) =>
      Container(
        constraints: BoxConstraints(maxHeight: height, maxWidth: width),
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Shimmer.fromColors(
          baseColor: CrystalColor.shimmerBackground,
          highlightColor: CrystalColor.shimmerHighlight,
          child: const ColoredBox(color: Colors.white),
        ),
      );
}
