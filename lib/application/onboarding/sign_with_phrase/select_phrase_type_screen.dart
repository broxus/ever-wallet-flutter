import 'package:ever_wallet/application/application.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/field/switch_field.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/generated/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SelectPhraseTypeRute extends MaterialPageRoute<void> {
  SelectPhraseTypeRute(String publicKey)
      : super(builder: (_) => SelectPhraseTypeScreen(publicKey: publicKey));
}

class SelectPhraseTypeScreen extends StatefulWidget {
  const SelectPhraseTypeScreen({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  final String publicKey;

  @override
  State<SelectPhraseTypeScreen> createState() => _SelectPhraseTypeScreenState();
}

class _SelectPhraseTypeScreenState extends State<SelectPhraseTypeScreen> {
  static const v3 = WalletType.walletV3();

  final isAdvancedWallets = ValueNotifier<bool>(false);
  final selectedWalletNotifier = ValueNotifier<WalletType>(v3);

  @override
  void initState() {
    isAdvancedWallets.addListener(() {
      if (!isAdvancedWallets.value && selectedWalletNotifier.value.toInt() != v3.toInt()) {
        selectedWalletNotifier.value = v3;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    selectedWalletNotifier.dispose();
    isAdvancedWallets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    // final localization = context.localization;

    return OnboardingBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: const OnboardingAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // TODO: replace text
                        'Select wallet type',
                        style: themeStyle.styles.appbarStyle,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        // TODO: replace text
                        'Depends on the type of transactions you want to make',
                        style: themeStyle.styles.basicStyle,
                      ),
                      const SizedBox(height: 28),
                      _walletTypeItem(
                        type: v3,
                        themeStyle: themeStyle,
                        name: v3.name,
                        description: v3.description(context),
                        isRecommended: true,
                      ),
                      const SizedBox(height: 40),
                      _advancedWallets(themeStyle),
                      const SizedBox(height: 40),
                      ValueListenableBuilder<bool>(
                        valueListenable: isAdvancedWallets,
                        builder: (_, isAdvanced, __) {
                          return AnimatedCrossFade(
                            duration: kThemeAnimationDuration,
                            crossFadeState:
                                isAdvanced ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            layoutBuilder: (
                              Widget topChild,
                              Key _,
                              Widget bottomChild,
                              Key __,
                            ) =>
                                Stack(
                              children: [
                                // 0 size to avoid scroll into nowhere
                                SizedBox(height: 0, width: 0, child: bottomChild),
                                topChild
                              ],
                            ),
                            firstChild: const SizedBox.shrink(),
                            secondChild: _walletsList(themeStyle),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                // TODO: replace text
                text: 'Create the wallet',
                onPressed: () async {
                  final type = selectedWalletNotifier.value;
                  await context.read<AccountsRepository>().addAccount(
                        name: type.name,
                        publicKey: widget.publicKey,
                        walletType: type,
                      );

                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.main, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _advancedWallets(ThemeStyle themeStyle) {
    return ValueListenableBuilder<bool>(
      valueListenable: isAdvancedWallets,
      builder: (_, isAdvanced, __) {
        return Row(
          children: [
            Expanded(
              child: Text(
                // TODO: replace text
                'Advanced wallet types',
                style: themeStyle.styles.basicStyle,
              ),
            ),
            EWSwitchField(
              value: isAdvanced,
              onChanged: (v) => isAdvancedWallets.value = v,
            ),
          ],
        );
      },
    );
  }

  Widget _walletTypeItem({
    required WalletType type,
    required ThemeStyle themeStyle,
    required String name,
    required String description,
    bool isRecommended = false,
  }) {
    return ValueListenableBuilder<WalletType>(
      valueListenable: selectedWalletNotifier,
      builder: (_, selectedType, __) {
        final isSelected = type.toInt() == selectedType.toInt();

        return GestureDetector(
          onTap: () {
            if (selectedWalletNotifier.value.toInt() != type.toInt()) {
              selectedWalletNotifier.value = type;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: isRecommended ? null : const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ColorsRes.lightBlue.withOpacity(0.1),
              border: Border.all(
                color: isSelected
                    ? ColorsRes.lightBlue.withOpacity(0.64)
                    : ColorsRes.lightBlue.withOpacity(0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      // TODO: replace text
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        color: ColorsRes.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.pt,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Text(
                        // TODO: replace text
                        'Recommended',
                        style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: ColorsRes.lightBlue.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: const Icon(Icons.check, color: ColorsRes.lightBlue, size: 23),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: themeStyle.styles.basicStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _walletsList(ThemeStyle themeStyle) {
    return StreamProvider<AsyncValue<Tuple2<List<WalletType>, List<WalletType>>>>(
      create: (context) => context
          .read<AccountsRepository>()
          .accountCreationOptions(widget.publicKey)
          .map((event) => AsyncValue.ready(event)),
      initialData: const AsyncValue.loading(),
      catchError: (context, error) => AsyncValue.error(error),
      builder: (context, child) {
        final options =
            context.watch<AsyncValue<Tuple2<List<WalletType>, List<WalletType>>>>().maybeWhen(
                  ready: (value) => value,
                  orElse: () => null,
                );

        final added = options?.item1 ?? [];
        final available = options?.item2 ?? [];

        final list = [...added, ...available]..sort((a, b) => a.toInt().compareTo(b.toInt()));
        list.removeWhere((w) => w.toInt() == v3.toInt());

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            list.length,
            (index) {
              final type = list[index];
              return _walletTypeItem(
                type: type,
                themeStyle: themeStyle,
                name: type.name,
                description: type.description(context),
              );
            },
          ),
        );
      },
    );
  }
}
