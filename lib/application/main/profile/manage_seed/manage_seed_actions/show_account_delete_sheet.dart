import 'package:auto_size_text/auto_size_text.dart';
import 'package:ever_wallet/application/bloc/common/account_overall_balance_stream.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/push_state_scale_widget.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

/// Show sheet to delete local or external account.
/// if account is external, then [linkedPublicKey] must be specified, for local not needed
Future<void> showAccountDeleteSheet({
  required BuildContext context,
  required AssetsList account,
  required bool isExternal,
  required String linkedPublicKey,
}) {
  return showEWBottomSheet(
    context,
    title: context.localization.delete_account_title(account.name),
    body: (_) => AccountDeleteSheet(
      account: account,
      isExternal: isExternal,
      linkedPublicKey: linkedPublicKey,
    ),
  );
}

class AccountDeleteSheet extends StatelessWidget {
  final AssetsList account;
  final bool isExternal;

  /// publicKey of key where [account] is linked to. Uses for external account
  final String linkedPublicKey;

  const AccountDeleteSheet({
    super.key,
    required this.account,
    required this.isExternal,
    required this.linkedPublicKey,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            localization.after_deletion_account_disappear,
            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
        ),
        PushStateScaleWidget(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: account.address));
            showFlushbar(
              context,
              message: localization.public_key_copied(account.address.ellipseAddress()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsRes.notWhite,
              border: Border.all(color: ColorsRes.grey2),
            ),
            child: Text(
              account.address,
              style: StylesRes.regular16.copyWith(color: ColorsRes.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              localization.total_balance,
              style: StylesRes.regular16.copyWith(color: ColorsRes.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AsyncValueStreamProvider<double>(
                create: (context) => accountOverallBalanceStream(
                  context.read<AccountsRepository>(),
                  context.read<TransportRepository>(),
                  context.read<TonWalletsRepository>(),
                  context.read<TokenWalletsRepository>(),
                  context.read<TokenCurrenciesRepository>(),
                  account.address,
                ),
                builder: (context, child) {
                  final balanceUsdt = context.watch<AsyncValue<double>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => null,
                      );

                  return balanceUsdt != null
                      ? balance(
                          balanceUsdt
                              .truncateToDecimalPlaces(4)
                              .toStringAsFixed(4)
                              .removeZeroes()
                              .formatValue(),
                        )
                      : const SizedBox();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        PrimaryElevatedButton(
          text: localization.delete_word,
          onPressed: () {
            if (isExternal) {
              context.read<AccountsRepository>().removeAccount(account.address);
            } else {
              context.read<AccountsRepository>().removeExternalAccount(
                    address: account.address,
                    publicKey: linkedPublicKey,
                  );
            }
            Navigator.of(context).pop();
          },
          isDestructive: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

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
}
