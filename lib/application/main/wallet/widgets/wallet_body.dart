import 'package:ever_wallet/application/bloc/account/current_account_cubit.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/widgets/animated_appearance.dart';
import 'package:ever_wallet/application/common/widgets/sliding_panel.dart';
import 'package:ever_wallet/application/main/wallet/widgets/connection_button.dart';
import 'package:ever_wallet/application/main/wallet/widgets/profile_actions.dart';
import 'package:ever_wallet/application/main/wallet/widgets/profile_carousel.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class WalletBody extends StatefulWidget {
  final PanelController modalController;

  const WalletBody({
    super.key,
    required this.modalController,
  });

  @override
  State<WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<WalletBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.wallet,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const ConnectionButton(),
                  ],
                ),
              ),
              const Gap(16),
              AnimatedAppearance(
                duration: const Duration(milliseconds: 250),
                offset: const Offset(1, 0),
                child: AsyncValueStreamProvider<List<AssetsList>>(
                  create: (context) =>
                      context.read<AccountsRepository>().currentAccountsStreamWithHidden,
                  builder: (context, child) {
                    final accounts = context.watch<AsyncValue<List<AssetsList>>>().maybeWhen(
                          ready: (value) => value,
                          orElse: () => <AssetsList>[],
                        );

                    return ProfileCarousel(
                      accounts: accounts,
                      onPageChanged: (i) {
                        if (i < accounts.length) {
                          context.read<CurrentAccountCubit>().setCurrent(accounts[i].address);
                        } else {
                          widget.modalController.hide();

                          context.read<CurrentAccountCubit>().setCurrent(null);
                        }
                      },
                      onPageSelected: (i) {
                        if (i == accounts.length) {
                          widget.modalController.hide();
                        } else {
                          widget.modalController.show();
                        }
                      },
                    );
                  },
                ),
              ),
              const Gap(16),
              BlocBuilder<CurrentAccountCubit, AssetsList?>(
                bloc: context.watch<CurrentAccountCubit>(),
                builder: (context, state) {
                  final currentAccount = state;

                  return currentAccount != null
                      ? ProfileActions(
                          key: ValueKey(currentAccount.address),
                          address: currentAccount.address,
                        )
                      : const SizedBox();
                },
              ),
              const Gap(20),
            ],
          ),
        ),
      );
}
