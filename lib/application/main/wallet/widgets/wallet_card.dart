import 'package:auto_size_text/auto_size_text.dart';
import 'package:ever_wallet/application/bloc/common/account_overall_balance_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/animated_appearance.dart';
import 'package:ever_wallet/application/common/widgets/wallet_card_selectable_field.dart';
import 'package:ever_wallet/application/main/wallet/widgets/more_button.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
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
  final String? publicKey;

  const WalletCard({
    Key? key,
    required this.address,
    this.publicKey,
  }) : super(key: key);

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
            StreamProvider<AsyncValue<TonWalletInfo?>>(
              create: (context) => context
                  .read<TonWalletsRepository>()
                  .getInfoStream(address)
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
              builder: (context, child) {
                final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return tonWalletInfo != null
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: MoreButton(
                          address: tonWalletInfo.address,
                          publicKey: publicKey,
                        ),
                      )
                    : const SizedBox();
              },
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
            StreamProvider<AsyncValue<AssetsList>>(
              create: (context) => context
                  .read<AccountsRepository>()
                  .accountInfo(address)
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
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
            StreamProvider<AsyncValue<TonWalletInfo?>>(
              create: (context) => context
                  .read<TonWalletsRepository>()
                  .getInfoStream(address)
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
              builder: (context, child) {
                final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return tonWalletInfo != null
                    ? namedField(
                        name: AppLocalizations.of(context)!.public_key,
                        value: tonWalletInfo.publicKey,
                        ellipsedValue: tonWalletInfo.publicKey.ellipsePublicKey(),
                      )
                    : namedField(
                        name: AppLocalizations.of(context)!.public_key,
                      );
              },
            ),
            StreamProvider<AsyncValue<TonWalletInfo?>>(
              create: (context) => context
                  .read<TonWalletsRepository>()
                  .getInfoStream(address)
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
              builder: (context, child) {
                final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return tonWalletInfo != null
                    ? namedField(
                        name: AppLocalizations.of(context)!.address,
                        value: tonWalletInfo.address,
                        ellipsedValue: tonWalletInfo.address.ellipseAddress(),
                      )
                    : namedField(
                        name: AppLocalizations.of(context)!.address,
                      );
              },
            ),
            StreamProvider<AsyncValue<TonWalletInfo?>>(
              create: (context) => context
                  .read<TonWalletsRepository>()
                  .getInfoStream(address)
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
              builder: (context, child) {
                final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => null,
                    );

                return tonWalletInfo != null
                    ? namedField(
                        name: AppLocalizations.of(context)!.type,
                        value: tonWalletInfo.walletType.describe(),
                        isSelectable: false,
                      )
                    : namedField(
                        name: AppLocalizations.of(context)!.type,
                        isSelectable: false,
                      );
              },
            ),
            const Spacer(),
            StreamProvider<AsyncValue<List<String>>>(
              create: (context) => context
                  .read<AccountsRepository>()
                  .currentExternalAccounts
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
              builder: (context, child) {
                final externalAccounts = context.watch<AsyncValue<List<String>>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => <String>[],
                    );

                return externalAccounts.any((e) => e == address)
                    ? externalAccountLabel(context)
                    : const SizedBox();
              },
            ),
            const Spacer(flex: 2),
            StreamProvider<AsyncValue<double>>(
              create: (context) => accountOverallBalanceStream(
                context.read<AccountsRepository>(),
                context.read<TransportRepository>(),
                context.read<TonWalletsRepository>(),
                context.read<TokenWalletsRepository>(),
                context.read<TokenCurrenciesRepository>(),
                address,
              ).map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
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
          child: Container(color: Colors.white),
        ),
      );
}
