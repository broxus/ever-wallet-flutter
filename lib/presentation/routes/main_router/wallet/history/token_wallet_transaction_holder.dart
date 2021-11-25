import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/utils/transaction_time.dart';
import '../../../../design/design.dart';
import '../../../../design/utils.dart';
import '../modals/transaction_observer/token_wallet_transaction_observer.dart';

class TokenWalletTransactionHolder extends StatelessWidget {
  final String currency;
  final int decimals;
  final Transaction transaction;
  final TokenWalletTransaction data;
  final Widget? icon;
  final String? sender;
  final String? recipient;
  final String value;

  TokenWalletTransactionHolder({
    Key? key,
    required this.currency,
    required this.decimals,
    required this.transaction,
    required this.data,
    this.icon,
  })  : sender = data.maybeWhen(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
          orElse: () => null,
        ),
        recipient = data.maybeWhen(
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
          swapBack: (tokenSwapBack) => tokenSwapBack.callbackAddress,
          orElse: () => null,
        ),
        value = data.when(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
          swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
          accept: (value) => value,
          transferBounced: (value) => value,
          swapBackBounced: (value) => value,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutgoing = recipient != null;
    final address = isOutgoing ? recipient : sender;

    return Material(
      color: CrystalColor.primary,
      child: CrystalInkWell(
        onTap: () => TokenWalletTransactionObserver.open(
          context: context,
          currency: currency,
          decimals: decimals,
          transaction: transaction,
          data: data,
          icon: icon,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: icon,
                )
              else
                const SizedBox(),
              const CrystalDivider(
                width: 16,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _getValueTitle(isOutgoing),
                        if (address != null) ...[
                          const CrystalDivider(
                            height: 2,
                          ),
                          _getLayout(address),
                        ],
                        const CrystalDivider(
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getValueTitle(bool isOutgoing) {
    final formattedValue = value.toTokens(decimals);

    return Text(
      isOutgoing ? '- ${formatValue(formattedValue)} $currency' : '${formatValue(formattedValue)} $currency',
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isOutgoing ? CrystalColor.error : CrystalColor.success,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _getLayout(String address) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getFees(),
              _getAddress(address),
            ],
          ),
          _getDate(),
        ],
      );

  Widget _getFees() => Text(
        'Fees: ${formatValue(transaction.totalFees.toTokens())} TON',
        style: const TextStyle(
          color: CrystalColor.fontSecondaryDark,
        ),
      );

  Widget _getAddress(String address) {
    return address.isNotEmpty
        ? Column(
            children: [
              const CrystalDivider(
                height: 6,
              ),
              SizedBox(
                width: 100,
                child: Text(
                  address.ellipseAddress(),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  softWrap: false,
                  style: const TextStyle(
                    letterSpacing: 0.25,
                    color: CrystalColor.fontDark,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget _getDate() => Text(
        DateFormat('MMM d, H:mm').format(transaction.createdAt.toDateTime()).toString(),
        style: const TextStyle(
          color: CrystalColor.fontDark,
        ),
      );

  Widget getStatusContainer({
    required String status,
    required Color color,
  }) =>
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  letterSpacing: 0.75,
                ),
              ),
            ),
          ),
        ],
      );
}