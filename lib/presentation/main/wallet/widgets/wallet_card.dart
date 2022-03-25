import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../data/extensions.dart';
import '../../../../../providers/account/account_info_provider.dart';
import '../../../../../providers/account/external_accounts_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../generated/codegen_loader.g.dart';
import '../../../common/extensions.dart';
import '../../../common/theme.dart';
import '../../../common/widgets/animated_appearance.dart';
import '../../../common/widgets/wallet_card_selectable_field.dart';
import 'more_button.dart';

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
                      child: info(),
                    ),
                    Expanded(flex: 6, child: pattern()),
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

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

  Widget info() => Padding(
        padding: const EdgeInsets.only(top: 23, left: 23, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final value = ref.watch(accountInfoProvider(address)).asData?.value;

                return value != null
                    ? AutoSizeText(
                        value.name,
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
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

                return tonWalletInfo != null
                    ? namedField(
                        name: LocaleKeys.fields_public_key.tr(),
                        value: tonWalletInfo.publicKey,
                        ellipsedValue: tonWalletInfo.publicKey.ellipsePublicKey(),
                      )
                    : namedField(
                        name: LocaleKeys.fields_public_key.tr(),
                      );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

                return tonWalletInfo != null
                    ? namedField(
                        name: LocaleKeys.fields_address.tr(),
                        value: tonWalletInfo.address,
                        ellipsedValue: tonWalletInfo.address.ellipseAddress(),
                      )
                    : namedField(
                        name: LocaleKeys.fields_address.tr(),
                      );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

                return tonWalletInfo != null
                    ? namedField(
                        name: LocaleKeys.fields_type.tr(),
                        value: tonWalletInfo.walletType.describe(),
                        isSelectable: false,
                      )
                    : namedField(
                        name: LocaleKeys.fields_type.tr(),
                        isSelectable: false,
                      );
              },
            ),
            const Spacer(),
            Consumer(
              builder: (context, ref, child) {
                final externalAccounts = ref.watch(externalAccountsProvider).asData?.value ?? [];

                return externalAccounts.any((e) => e == address) ? externalAccountLabel() : const SizedBox();
              },
            ),
            const Spacer(flex: 2),
            Consumer(
              builder: (context, ref, child) {
                final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

                return tonWalletInfo != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: balance(tonWalletInfo.contractState.balance),
                      )
                    : const SizedBox();
              },
            ),
          ],
        ),
      );

  Widget externalAccountLabel() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.iconMultisig.svg(),
          const SizedBox(width: 8),
          const Text(
            'External account',
            style: TextStyle(color: Colors.white),
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
          const SizedBox(width: 8),
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
    final formattedString = balance.toTokens().floorValue().removeZeroes().formatValue();

    return AutoSizeText.rich(
      TextSpan(
        text: formattedString.contains('.')
            ? formattedString.substring(0, formattedString.indexOf('.'))
            : formattedString,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0.75,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: formattedString.contains('.')
                ? "${formattedString.substring(formattedString.indexOf('.'), formattedString.length)} EVER"
                : ' EVER',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 0.75,
              fontWeight: FontWeight.normal,
            ),
          )
        ],
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
