import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/repositories/accounts_storage_repository.dart';
import '../../../../../data/repositories/current_key_repository.dart';
import '../../../../../data/repositories/external_accounts_repository.dart';
import '../../../../../injection.dart';
import '../../../../../providers/account/external_accounts_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/custom_popup_item.dart';
import '../../../../design/widgets/custom_popup_menu.dart';
import '../modals/account_removement_modal/show_account_removement_modal.dart';
import '../modals/custodians_modal/show_custodians_modal.dart';
import '../modals/preferences_modal/show_preferences_modal.dart';

class MoreButton extends StatelessWidget {
  final String address;
  final String? publicKey;

  const MoreButton({
    Key? key,
    required this.address,
    this.publicKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

          return CustomPopupMenu(
            items: [
              _Actions.preferences,
              if (tonWalletInfo?.custodians?.isNotEmpty ?? false) _Actions.custodians,
              _Actions.removeAccount,
            ]
                .map(
                  (e) => CustomPopupItem(
                    title: Text(
                      e.describe(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () => onSelected(context: context, read: ref.read, value: e),
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
    required Reader read,
    required _Actions value,
  }) {
    switch (value) {
      case _Actions.preferences:
        showPreferencesModal(
          context: context,
          address: address,
          publicKey: publicKey,
        );
        break;
      case _Actions.custodians:
        showCustodiansModal(
          context: context,
          address: address,
        );
        break;
      case _Actions.removeAccount:
        showAccountRemovementDialog(
          context: context,
          address: address,
          onDeletePressed: () async {
            final externalAccounts = await read(externalAccountsProvider.future);

            if (externalAccounts.any((e) => e == address)) {
              final currentKey = getIt.get<CurrentKeyRepository>().currentKey;

              await getIt.get<ExternalAccountsRepository>().removeExternalAccount(
                    publicKey: currentKey!.publicKey,
                    address: address,
                  );
            } else {
              await getIt.get<AccountsStorageRepository>().removeAccount(address);
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
  String describe() {
    switch (this) {
      case _Actions.preferences:
        return 'Preferences';
      case _Actions.custodians:
        return 'Custodians';
      case _Actions.removeAccount:
        return 'Remove account';
    }
  }
}
