import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_radio.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/transport_builder.dart';
import 'package:ever_wallet/application/main/browser/common/grant_permissions_page.dart';
import 'package:ever_wallet/application/main/browser/common/selected_account_cubit.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class RequestPermissionsPage extends StatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final List<Permission> permissions;

  const RequestPermissionsPage({
    super.key,
    required this.modalContext,
    required this.origin,
    required this.permissions,
  });

  @override
  _RequestPermissionsModalState createState() =>
      _RequestPermissionsModalState();
}

class _RequestPermissionsModalState extends State<RequestPermissionsPage> {
  @override
  Widget build(BuildContext context) => BlocProvider<SelectedAccountCubit>(
        create: (context) => SelectedAccountCubit(
            context.read<AccountsRepository>().currentAccounts.firstOrNull),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ModalHeader(
                    text: AppLocalizations.of(context)!.select_account,
                    onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                  ),
                  const Gap(16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: accounts(),
                    ),
                  ),
                  const Gap(16),
                  buttons(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget accounts() => AsyncValueStreamProvider<List<AssetsList>>(
        create: (context) =>
            context.read<AccountsRepository>().currentAccountsStream,
        builder: (context, child) {
          final accounts =
              context.watch<AsyncValue<List<AssetsList>>>().maybeWhen(
                    ready: (value) => value,
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

  Widget accountTile(AssetsList account) => Builder(
        builder: (context) {
          return InkWell(
            onTap: () => context.read<SelectedAccountCubit>().select(account),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 4,
              ),
              child: Row(
                children: [
                  radio(account),
                  AddressGeneratedIcon(address: account.address),
                  const Gap(16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name(account),
                      const Gap(4),
                      balance(account),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget radio(AssetsList account) => AbsorbPointer(
        child: BlocBuilder<SelectedAccountCubit, AssetsList?>(
          builder: (context, state) => CustomRadio<AssetsList>(
            value: account,
            groupValue: state,
            onChanged: (value) {},
          ),
        ),
      );

  Widget name(AssetsList account) => Text(
        account.name,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      );

  Widget balance(AssetsList account) => AsyncValueStreamProvider<String>(
        create: (context) => context
            .read<TonWalletsRepository>()
            .contractStateStream(account.address)
            .map((e) => e.balance),
        builder: (context, child) {
          final balance = context.watch<AsyncValue<String>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return TransportBuilderWidget(
            builder: (context, data) {
              return Text(
                '${balance?.toTokens().removeZeroes().formatValue() ?? '0'} ${data.config.symbol}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              );
            },
          );
        },
      );

  Widget buttons() => Row(
        children: [
          Expanded(
            child: rejectButton(),
          ),
          const Gap(16),
          Expanded(
            flex: 2,
            child: submitButton(),
          ),
        ],
      );

  Widget rejectButton() => CustomOutlinedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: AppLocalizations.of(context)!.cancel,
      );

  Widget submitButton() => BlocBuilder<SelectedAccountCubit, AssetsList?>(
        builder: (context, state) => CustomElevatedButton(
          onPressed: state != null ? () => onSubmitPressed(state) : null,
          text: AppLocalizations.of(context)!.select,
        ),
      );

  Future<void> onSubmitPressed(AssetsList account) async =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => GrantPermissionsPage(
            modalContext: widget.modalContext,
            origin: widget.origin,
            account: account,
            permissions: widget.permissions,
            onSubmit: (permissions) =>
                Navigator.of(widget.modalContext).pop(permissions),
          ),
        ),
      );
}
