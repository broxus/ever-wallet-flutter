import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import '../../../../design/widgets/crystal_bottom_sheet.dart';

class CallContractMethodBody extends StatefulWidget {
  final String origin;
  final String publicKey;
  final String recipient;
  final FunctionCall? payload;

  const CallContractMethodBody._({
    Key? key,
    required this.origin,
    required this.publicKey,
    required this.recipient,
    required this.payload,
  }) : super(key: key);

  static Future<bool?> open({
    required BuildContext context,
    required String origin,
    required String publicKey,
    required String recipient,
    required FunctionCall? payload,
  }) =>
      showCrystalBottomSheet<bool>(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: 'Call contract method',
        body: CallContractMethodBody._(
          origin: origin,
          publicKey: publicKey,
          recipient: recipient,
          payload: payload,
        ),
      );

  @override
  _CallContractMethodBodyState createState() => _CallContractMethodBodyState();
}

class _CallContractMethodBodyState extends State<CallContractMethodBody> {
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
              text: 'Call',
              onTap: onAllowTapped,
            ),
          ),
        ],
      );
}
