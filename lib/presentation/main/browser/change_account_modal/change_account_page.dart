import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../data/models/permission.dart';
import '../../../../generated/codegen_loader.g.dart';
import '../../../../providers/account/accounts_provider.dart';
import '../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../common/constants.dart';
import '../../../common/extensions.dart';
import '../../../common/widgets/address_generated_icon.dart';
import '../../../common/widgets/custom_elevated_button.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../common/widgets/custom_radio.dart';
import '../../../common/widgets/modal_header.dart';
import '../common/grant_permissions_page.dart';
import 'change_account_page_logic.dart.dart';

class ChangeAccountPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final List<Permission> permissions;

  const ChangeAccountPage({
    Key? key,
    required this.modalContext,
    required this.origin,
    required this.permissions,
  }) : super(key: key);

  @override
  _RequestPermissionsModalState createState() => _RequestPermissionsModalState();
}

class _RequestPermissionsModalState extends ConsumerState<ChangeAccountPage> {
  @override
  void initState() {
    super.initState();
    ref.read(accountsProvider).whenData(
          (value) => WidgetsBinding.instance.addPostFrameCallback(
            (_) => ref.read(selectedAccountProvider.notifier).state = value.firstOrNull,
          ),
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ModalHeader(
                  text: LocaleKeys.change_account.tr(),
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: accounts(),
                  ),
                ),
                const SizedBox(height: 16),
                buttons(),
              ],
            ),
          ),
        ),
      );

  Widget accounts() => Consumer(
        builder: (context, ref, child) {
          final accounts = ref.watch(accountsProvider).maybeWhen(
                data: (data) => data,
                orElse: () => <AssetsList>[],
              );

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => accountTile(accounts[index]),
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
            ),
            itemCount: accounts.length,
          );
        },
      );

  Widget accountTile(AssetsList account) => Consumer(
        builder: (context, ref, child) => InkWell(
          onTap: () => ref.read(selectedAccountProvider.notifier).state = account,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            child: Row(
              children: [
                radio(account),
                AddressGeneratedIcon(address: account.address),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name(account),
                    const SizedBox(height: 4),
                    balance(account),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget radio(AssetsList account) => AbsorbPointer(
        child: Consumer(
          builder: (context, ref, child) {
            final selectedAccount = ref.watch(selectedAccountProvider);

            return CustomRadio<AssetsList>(
              value: account,
              groupValue: selectedAccount,
              onChanged: (value) {},
            );
          },
        ),
      );

  Widget name(AssetsList account) => Text(
        account.name,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      );

  Widget balance(AssetsList account) => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(account.address)).whenOrNull(data: (data) => data);

          return Text(
            '${tonWalletInfo?.contractState.balance.toTokens().removeZeroes().formatValue() ?? '0'} $kEverTicker',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          );
        },
      );

  Widget buttons() => Row(
        children: [
          Expanded(
            child: rejectButton(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: submitButton(),
          ),
        ],
      );

  Widget rejectButton() => CustomOutlinedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: LocaleKeys.cancel.tr(),
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final selectedAccount = ref.watch(selectedAccountProvider);

          return CustomElevatedButton(
            onPressed: selectedAccount != null ? () => onSubmitPressed(selectedAccount) : null,
            text: LocaleKeys.select.tr(),
          );
        },
      );

  Future<void> onSubmitPressed(AssetsList account) async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => GrantPermissionsPage(
            modalContext: widget.modalContext,
            origin: widget.origin,
            account: account,
            permissions: widget.permissions,
            onSubmit: (permissions) => Navigator.of(widget.modalContext).pop(permissions),
          ),
        ),
      );
}
