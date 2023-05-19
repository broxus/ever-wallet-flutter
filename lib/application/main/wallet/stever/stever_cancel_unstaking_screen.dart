import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/send_info_page.dart';
import 'package:ever_wallet/application/main/wallet/stever/stever_result_screen.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/models/stever/stever_withdraw_request.dart';
import 'package:ever_wallet/data/repositories/stever_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

/// Screen that displays information about unstake operation and let it be cancelled
class StEverCancelUnstakingSheet extends StatelessWidget {
  const StEverCancelUnstakingSheet({
    required this.request,
    required this.exchangeRate,
    required this.publicKey,
    super.key,
  });

  final String publicKey;
  final StEverWithdrawRequest request;
  final double exchangeRate;

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            color: ColorsRes.blue950,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              localization.withdraw_72_hours_note,
              style: StylesRes.regular14.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(height: 28),
          _sectionItem(
            localization.status_word,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: ColorsRes.caution.withOpacity(0.1),
              ),
              child: Text(
                localization.unstaking_progress,
                style: StylesRes.captionText.copyWith(color: ColorsRes.caution),
              ),
            ),
          ),
          const DefaultDivider(),
          _textSectionItem(localization.type, 'Liquid Staking'),
          const DefaultDivider(),
          _textSectionItem(
            localization.unstake_amount,
            '${request.data.amount.toTokensFull()} $kStEverTicker',
          ),
          const DefaultDivider(),
          _textSectionItem(
            localization.exchange_rate,
            '1 $kStEverTicker ≈ ${exchangeRate.toStringAsFixed(4)} $kEverTicker',
          ),
          const DefaultDivider(),
          _textSectionItem(
            localization.receive,
            '~${(double.parse(request.data.amount.toTokensFull().replaceAll(',', '')) * exchangeRate).toStringAsFixed(4)} $kEverTicker',
          ),
          const SizedBox(height: 30),
          Text(
            localization.recipient,
            style: StylesRes.regular16.copyWith(color: ColorsRes.neutral400),
          ),
          const SizedBox(height: 4),
          Text(
            request.accountAddress,
            style: StylesRes.captionText.copyWith(color: ColorsRes.bluePrimary400),
          ),
          const SizedBox(height: 30),
          TextPrimaryButton(
            fillWidth: false,
            padding: EdgeInsets.zero,
            onPressed: () => _cancelUnstaking(context),
            text: localization.cancel_unstaking,
            style: StylesRes.medium16.copyWith(color: ColorsRes.red400Primary),
          ),
          const SizedBox(height: 4),
          Text(
            localization.cancel_unstaking_note,
            style: StylesRes.regular14.copyWith(color: ColorsRes.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _textSectionItem(String title, String value, [bool isBold = false]) {
    return _sectionItem(
      title,
      Text(
        value,
        style: (isBold ? StylesRes.bold20 : StylesRes.medium16).copyWith(color: ColorsRes.black),
      ),
    );
  }

  Widget _sectionItem(String title, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: StylesRes.regular16.copyWith(color: ColorsRes.neutral400),
          ),
          value,
        ],
      ),
    );
  }

  Future<void> _cancelUnstaking(BuildContext context) async {
    final rep = context.read<StEverRepository>();
    final message = rep.removeWithdraw(
      accountAddress: request.accountAddress,
      nonce: request.nonce,
    );
    final body = encodeInternalInput(
      contractAbi: message.payload!.abi,
      method: message.payload!.method,
      input: message.payload!.params,
    );
    final navigator = Navigator.of(context);
    navigator.pop();

    final success = await showPlatformModalBottomSheet<bool>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => SendInfoPage(
            modalContext: context,
            address: message.sender,
            publicKey: publicKey,
            destination: repackAddress(message.recipient),
            amount: message.amount,
            comment: body,
            resultBuilder: (modalContext) => StEverResultScreen(
              title: context.localization.unstaking_cancelled,
              subtitle: context.localization.stever_return_in_minutes,
              isCompleted: true,
              modalContext: modalContext,
            ),
          ),
        ),
      ),
    );

    if (success ?? false) {
      rep.acceptCancelledWithdraw(request);
      navigator.pop();
    }
  }
}
