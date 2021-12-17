import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import '../../../../design/widgets/crystal_bottom_sheet.dart';

class SendMessageBody extends StatefulWidget {
  final String origin;
  final String sender;
  final String publicKey;
  final String recipient;
  final String amount;
  final bool bounce;
  final FunctionCall? payload;
  final KnownPayload? knownPayload;

  const SendMessageBody._({
    Key? key,
    required this.origin,
    required this.sender,
    required this.publicKey,
    required this.recipient,
    required this.amount,
    required this.bounce,
    required this.payload,
    required this.knownPayload,
  }) : super(key: key);

  static Future<bool?> open({
    required BuildContext context,
    required String origin,
    required String sender,
    required String publicKey,
    required String recipient,
    required String amount,
    required bool bounce,
    required FunctionCall? payload,
    required KnownPayload? knownPayload,
  }) =>
      showCrystalBottomSheet<bool>(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: 'Send message',
        body: SendMessageBody._(
          origin: origin,
          sender: sender,
          publicKey: publicKey,
          recipient: recipient,
          amount: amount,
          bounce: bounce,
          payload: payload,
          knownPayload: knownPayload,
        ),
      );

  @override
  _SendMessageBodyState createState() => _SendMessageBodyState();
}

class _SendMessageBodyState extends State<SendMessageBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                color: CrystalColor.grayBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildInfo(
                      title: 'Origin',
                      value: widget.origin,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: 'Account address',
                      value: widget.sender,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: 'Account public key',
                      value: widget.publicKey,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: 'Recipient address',
                      value: widget.recipient,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: 'Amount',
                      value: widget.amount.toTokens(),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: 'Bounce',
                      value: widget.bounce ? 'Yes' : 'No',
                    ),
                  ],
                ),
              ),
              buildButtons(
                onDenyTapped: () => Navigator.of(context).pop(false),
                onAllowTapped: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      );

  Widget buildInfo({
    required String title,
    required String value,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CrystalColor.fontTitleSecondaryDark,
              fontSize: 16,
            ),
          ),
          const CrystalDivider(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: CrystalColor.fontDark,
            ),
          ),
        ],
      );

  Widget buildButtons({
    required VoidCallback onDenyTapped,
    required VoidCallback onAllowTapped,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CrystalButton(
              type: CrystalButtonType.outline,
              text: 'Reject',
              onTap: onDenyTapped,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CrystalButton(
              text: 'Send',
              onTap: onAllowTapped,
            ),
          ),
        ],
      );
}
