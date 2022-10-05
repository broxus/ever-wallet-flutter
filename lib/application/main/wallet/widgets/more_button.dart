import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_item.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_menu.dart';
import 'package:ever_wallet/application/main/wallet/modals/account_removement_modal/show_account_removement_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/custodians_modal/show_custodians_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/preferences_modal/show_preferences_modal.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MoreButton extends StatefulWidget {
  final String address;
  final String? publicKey;

  const MoreButton({
    super.key,
    required this.address,
    this.publicKey,
  });

  @override
  State<MoreButton> createState() => _MoreButtonState();
}

class _MoreButtonState extends State<MoreButton> {
  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<List<String>?>(
        create: (context) => context.read<TonWalletsRepository>().custodiansStream(widget.address),
        builder: (context, child) {
          final custodians = context.watch<AsyncValue<List<String>?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return CustomPopupMenu(
            items: [
              _Actions.preferences,
              if (custodians?.isNotEmpty ?? false) _Actions.custodians,
              _Actions.removeAccount,
            ]
                .map(
                  (e) => CustomPopupItem(
                    title: Text(
                      e.describe(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () => onSelected(context: context, value: e),
                  ),
                )
                .toList(),
            icon: Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: CrystalColor.actionBackground.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
            ),
          );
        },
      );

  void onSelected({
    required BuildContext context,
    required _Actions value,
  }) {
    switch (value) {
      case _Actions.preferences:
        showPreferencesModal(
          context: context,
          address: widget.address,
          publicKey: widget.publicKey,
        );
        break;
      case _Actions.custodians:
        showCustodiansModal(
          context: context,
          address: widget.address,
        );
        break;
      case _Actions.removeAccount:
        showAccountRemovementDialog(
          context: context,
          address: widget.address,
          onDeletePressed: () async {
            final externalAccounts = context.read<AccountsRepository>().externalAccounts;

            if (externalAccounts.values.expand((e) => e).any((e) => e == widget.address)) {
              if (!mounted) return;

              final currentKey = context.read<KeysRepository>().currentKey;

              await context.read<AccountsRepository>().removeExternalAccount(
                    publicKey: currentKey!,
                    address: widget.address,
                  );
            } else {
              if (!mounted) return;

              await context.read<AccountsRepository>().removeAccount(widget.address);
            }
          },
        );
        break;
    }
  }
}

enum _Actions {
  preferences,
  custodians,
  removeAccount,
}

extension on _Actions {
  String describe(BuildContext context) {
    switch (this) {
      case _Actions.preferences:
        return AppLocalizations.of(context)!.preferences;
      case _Actions.custodians:
        return AppLocalizations.of(context)!.custodians;
      case _Actions.removeAccount:
        return AppLocalizations.of(context)!.remove_account;
    }
  }
}
